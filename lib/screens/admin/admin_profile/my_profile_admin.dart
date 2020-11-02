import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/admin_profile/quiz_submissions.dart';
import 'package:q_and_a/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:q_and_a/shared/widgets.dart';

class MyProfileAdmin extends StatefulWidget {

  final UserModel currentUser;

  MyProfileAdmin({this.currentUser});

  @override
  _MyProfileAdminState createState() => _MyProfileAdminState();
}

class _MyProfileAdminState extends State<MyProfileAdmin> {

  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AnimationConfiguration.synchronized(
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "My Profile",
                          style: TextStyle(fontSize: 35.0, color: Colors.black54),
                        ),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    widget.currentUser.photoUrl,
                                  ),
                                  radius: 50,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 18.0,),
                                        SizedBox(width: 10,),
                                        Text(widget.currentUser.displayName, style: TextStyle(fontSize: 20.0),),
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.email, size: 20.0,),
                                        SizedBox(width: 10,),
                                        Column(
                                          children: [
                                            Text(widget.currentUser.email.toString().split("@")[0], style: TextStyle(fontSize: 20.0, color: Colors.black),),
                                            Text("@${widget.currentUser.email.toString().split("@")[1]}", style: TextStyle(fontSize: 15.0, color: Colors.black54),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Hero(
                          tag: "quiz_submissions",
                          child: blueButton(
                            context: context,
                            label: "View Quiz Submissions",
                            onPressed: () {
                              // print("## $teacherId");
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => QuizSubmissions(teacherId: widget.currentUser.uid,)
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
}
