import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/screens/shared_screens/user_details_tile.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ChangeTeachers extends StatefulWidget {

  final String currentTeacherEmail;
  final StudentModel currentUser;
  ChangeTeachers({this.currentTeacherEmail, this.currentUser});

  @override
  _ChangeTeachersState createState() => _ChangeTeachersState();
}

class _ChangeTeachersState extends State<ChangeTeachers> {

  final _formKey = GlobalKey<FormState>();
  final DatabaseService databaseService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String teacherEmail;
  bool _isLoading = false;

  SnackBar _snackBarWithText(String text) {
    final snackBar = SnackBar(
      content: Text(text, style: TextStyle(fontSize: 15.0),),
      backgroundColor: Colors.blueAccent,
    );
    return snackBar;
  }

  _showDeleteTeacherAlert({BuildContext context, String displayName, String email}) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: "Delete Teacher\n\"$displayName\" ?",
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            databaseService.removeTeacher(userId: widget.currentUser.uid, teacherEmail: email).then((value) {
              Navigator.pop(context);
            });
          },
          gradient: LinearGradient(colors: [
            Colors.blue[500],
            Colors.blue[400],
          ]),
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Colors.blue[400],
            Colors.blue[500],
          ]),
        )
      ],
    ).show();
  }

  _showAddTeacher(BuildContext context) {
    Alert(
        context: context,
        type: AlertType.none,
        title: "Add Teacher",
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
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              if(_formKey.currentState.validate()) {
                QuerySnapshot result = await databaseService.getUserDocumentWithField(
                    fieldKey: "email",
                    fieldValue: teacherEmail,
                    limit: 1,
                );
                if(result.docs.length > 0) {
                  if(result.docs[0].data().containsKey("isAdmin")) {
                    if(result.docs[0].data()["isAdmin"] != true) {
                      SnackBar snackBar = _snackBarWithText("Email \"$teacherEmail\" is not registered as Teacher, try again with different email");
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    } else {

                      Map<String, String> teacherMap = {
                        "displayName" : result.docs[0].data()["displayName"],
                        "email" : result.docs[0].data()['email'],
                        "photoUrl" : result.docs[0].data()['photoUrl']
                      };

                      databaseService.addTeacher(userId: widget.currentUser.uid, teacherData: teacherMap).then((value) {
                        SnackBar snackBar = _snackBarWithText("Teacher \"${teacherMap['displayName']}\" added successfully");
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      });
                    }
                  } else {
                    SnackBar snackBar = _snackBarWithText("Email \"$teacherEmail\" is not registered.");
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                } else {
                  SnackBar snackBar = _snackBarWithText("Email \"$teacherEmail\" is not registered.");
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                }

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        title: appBar(context),
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Colors.blue
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.plus, size: 20.0,),
            onPressed: () {
              _showAddTeacher(context);
            },
          ),
        ],
      ),
      body: _isLoading ? Loading(loadingText: "Just a moment",) : Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
        child: StreamBuilder(
          stream: databaseService.getTeachersOfUser(userId: widget.currentUser.uid),
          builder: (context, snapshots) {
            if( !snapshots.hasData) {
              return Loading();
            } else if (snapshots.data.docs.length == 0) {
              return InfoDisplay(
                textToDisplay: "You have not added any teachers here, add your teachers now!",
              );
            } else {
              return SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: [
                    Text("Your Teachers", style: TextStyle(fontSize: 20.0),),
                    SizedBox(height: 10.0,),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshots.data.docs.length,
                        itemBuilder: (context, index) {

                          bool isHighlightTile = false;
                          if(snapshots.data.docs[index].data()["email"] == widget.currentTeacherEmail) {
                            isHighlightTile = true;
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: GestureDetector(
                              onTap: () {
                                databaseService.updateTeacherEmail(
                                  studentModel: widget.currentUser,
                                  newTeacherEmail: snapshots.data.docs[index].data()["email"].toString().trim(),
                                  currentTeacherEmail: widget.currentTeacherEmail,
                                ).whenComplete(() {
                                  Navigator.of(context).pop(snapshots.data.docs[index].data()["email"].toString().trim());
                                });
                              },
                              onLongPress: isHighlightTile ? () {
                                final snackBar = SnackBar(
                                  content: Text("Cannot delete currently selected teacher", style: TextStyle(fontSize: 15.0),),
                                  backgroundColor: Colors.blueAccent,
                                );
                                _scaffoldKey.currentState.showSnackBar(snackBar);
                              } : () {
                                _showDeleteTeacherAlert(
                                  context: context,
                                  displayName: snapshots.data.docs[index].data()["displayName"],
                                  email: snapshots.data.docs[index].data()["email"],
                                );
                              },
                              child: UserDetailsTile(
                                displayName: snapshots.data.docs[index].data()["displayName"],
                                email: snapshots.data.docs[index].data()["email"],
                                photoUrl: snapshots.data.docs[index].data()["photoUrl"],
                                isHighlightTile: isHighlightTile,
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
