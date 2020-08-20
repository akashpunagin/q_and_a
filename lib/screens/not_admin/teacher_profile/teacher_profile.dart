import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/send_email.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TeacherProfile extends StatefulWidget {

  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {

  final DatabaseService databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  String teacherEmail;
  String teacherEmailToStream = "";
  bool _isLoading = false;

  Map<String, dynamic> studentDetails = {
    "nTotalQuizSubmitted" : 0,
    "nTotalCorrect" : 0,
    "nTotalWrong" : 0,
    "nTotalNotAttempted" : 0,
    "studentName" : "",
  };

  _showPopUp(BuildContext context, String userId) {
    Alert(
        context: context,
        type: AlertType.none,
        title: "Edit Teacher Email",
        style: alertStyle,
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (val) => val.isEmpty ? "Enter email" : null,
                onChanged: (val) {
                    teacherEmail = val;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: 'Email',
                  hintText: "example@gmail.com"
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              if(_formKey.currentState.validate()) {
                databaseService.updateTeacherEmail(userId: userId, teacherEmail: teacherEmail.toString().trim()).then((val) {
                });
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    DocumentReference result = databaseService.getUserWithUserId(user.uid);
    Future<bool> isTeacherEmailExists = result.get().then((result) async {

      setState(() {
        studentDetails['nTotalCorrect'] = result.data.containsKey("nTotalCorrect") ?  result.data["nTotalCorrect"] : 0;
        studentDetails['nTotalWrong'] = result.data.containsKey("nTotalWrong") ?  result.data["nTotalWrong"] : 0;
        studentDetails['nTotalQuizSubmitted'] = result.data.containsKey("nTotalQuizSubmitted") ?  result.data["nTotalQuizSubmitted"] : 0;
        studentDetails['nTotalNotAttempted'] = result.data.containsKey("nTotalNotAttempted") ?  result.data["nTotalNotAttempted"] : 0;
        studentDetails['studentName'] = result.data['displayName'];
      });

      if ( result.data.containsKey("teacherEmail") ) {
        setState(() {
          teacherEmailToStream = result.data['teacherEmail'];
        });
      }
      return result.data.containsKey("teacherEmail");
    });

    return Scaffold(
      body: _isLoading ? Loading() : Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: FutureBuilder(
          future: isTeacherEmailExists,
          builder: (context, future) {
            if(future.data == null) {
              return Loading();
            } else if (future.data == false) {
              return InfoDisplay(
                textToDisplay: "Update your Teacher email",
              );
            } else {
              return StreamBuilder(
                  stream: databaseService.getUserWithField(
                      fieldKey: "email",
                      fieldValue: teacherEmailToStream,
                      limit: 1),
                  builder: (context, snapshots) {
                    if ( !snapshots.hasData ) {
                      return Loading();
                    } else if(snapshots.hasData && snapshots.data.documents.length !=0 && snapshots.data.documents[0].data['isAdmin'] == false) {
                      return InfoDisplay(
                        textToDisplay: "The email \"${snapshots.data.documents[0].data['email']}\" is not registered as teacher, edit your Teacher email",
                      );
                    } else if ( snapshots.hasData && snapshots.data.documents.length > 0) {
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(
                                      "Your Teacher",
                                      style: TextStyle(
                                        fontSize: 35.0,
                                      ),
                                    ),
                                    Image.network(
                                        snapshots.data.documents[0].data['photoUrl']
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20.0,),
                                        SizedBox(width: 10,),
                                        Text(snapshots.data.documents[0].data['displayName'], style: TextStyle(fontSize: 25.0),)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.email),
                                        SizedBox(width: 5,),
                                        Text(snapshots.data.documents[0].data['email'], style: TextStyle(fontSize: 20.0),)
                                      ],
                                    ),
                                    snapshots.hasData && snapshots.data.documents.length > 0 ? blueButton(context: context, label: "Send your progress to ${snapshots.data.documents[0].data['displayName']}", onPressed: (){
                                      displaySelectGmailAlert(context: context, onPressed: () {
                                        SendEmail sendEmail = SendEmail();
                                        sendEmail.teacherEmail = snapshots.data.documents[0].data['email'];
                                        sendEmail.studentName = studentDetails['studentName'];
                                        sendEmail.studentId = user.uid;
                                        sendEmail.sendEmailProgress();
                                      });
                                    }) : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Image.asset(
                              "assets/images/teacher_profile.png"
                            ),
                          ],
                        ),
                      );
                    }
                    else {
                      return InfoDisplay(
                        textToDisplay: "Didn't find any teachers with email \"$teacherEmailToStream\".\nEdit your Teacher Email.",
                      );
                    }
                  }
              );
            }

          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPopUp(context, user.uid);
        },
        child: FaIcon(FontAwesomeIcons.userEdit, size: 20.0,),
      ),
    );
  }
}
