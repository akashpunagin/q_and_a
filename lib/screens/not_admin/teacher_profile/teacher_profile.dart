import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/send_email.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'change_teachers.dart';

class TeacherProfile extends StatefulWidget {

  final StudentModel currentUser;

  TeacherProfile({this.currentUser});

  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {

  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: widget.currentUser.teacherEmail == null ? InfoDisplay(
          textToDisplay: "You have not selected any teachers yet",
        ) : Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimationConfiguration.synchronized(
                  child: SlideAnimation(
                    verticalOffset: 20,
                    child: FadeInAnimation(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            screenLabel(
                                child: Text(
                                  "My Teacher",
                                  style: TextStyle(fontSize: 20.0, color: Colors.black54),
                                ),
                                context: context
                            ),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          widget.currentUser.teacherPhotoUrl
                                      ),
                                      radius: 45,
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 18.0,),
                                        SizedBox(width: 5,),
                                        Text(widget.currentUser.teacherName, style: TextStyle(fontSize: 22.0),)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.email, size: 20.0,),
                                        SizedBox(width: 5,),
                                        Text(widget.currentUser.teacherEmail, style: TextStyle(fontSize: 18.0),)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            blueButton(
                                context: context, label: "Send your progress to ${widget.currentUser.teacherName}",
                                onPressed: (){
                                  displaySelectGmailAlert(context: context, onPressed: () {
                                    SendEmail sendEmail = SendEmail();
                                    sendEmail.teacherEmail = widget.currentUser.teacherEmail;
                                    sendEmail.studentName = widget.currentUser.displayName;
                                    sendEmail.studentId = widget.currentUser.uid;
                                    sendEmail.sendEmailProgress();
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Image.asset(
                "assets/images/teacher_profile.png",
                width: MediaQuery.of(context).size.height * 0.4,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(widget.currentUser.teacherEmail != "") {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChangeTeachers(
                  currentTeacherEmail: widget.currentUser.teacherEmail,
                  currentUser: widget.currentUser,
                )
            )).then((value) {
              if(value != null) {
                setState(() {
                  widget.currentUser.teacherEmail = value['email'];
                  widget.currentUser.teacherName = value['displayName'];
                  widget.currentUser.teacherPhotoUrl = value['photoUrl'];
                  widget.currentUser.teacherId = value['teacherId'];
                });
              }
            });
          }
        },
        child: FaIcon(FontAwesomeIcons.userPlus, size: 20.0,),
      ),
    );
  }
}
