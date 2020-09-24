import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/not_admin/not_admin_profile/student_progress.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyProfileNotAdmin extends StatefulWidget {

  final StudentModel currentUser;

  MyProfileNotAdmin({Key key, this.currentUser}) : super(key: key);

  @override
  _MyProfileNotAdminState createState() => _MyProfileNotAdminState();
}

class _MyProfileNotAdminState extends State<MyProfileNotAdmin> {

  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("My Profile",style: TextStyle(fontSize: 40.0, color: Colors.black54),),
                    Text("Correct Answers : ${widget.currentUser.nTotalCorrect}", style: TextStyle(fontSize: 18),),
                    Text("Wrong Answers : ${widget.currentUser.nTotalWrong}", style: TextStyle(fontSize: 18),),
                    Text("Not Attempted : ${widget.currentUser.nTotalNotAttempted}", style: TextStyle(fontSize: 18),),
                    Text("Total Quiz Submitted : ${widget.currentUser.nTotalQuizSubmitted}", style: TextStyle(fontSize: 18),),
                    blueButton(context: context, label: "View your progress", onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => StudentProgress(userId: widget.currentUser.uid,)
                      ));
                    }),
                  ],
                ),
              ),
            ),
            Container(
              child: Stack(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      "assets/images/wave_2.png",
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.currentUser.photoUrl,
                          ),
                          radius: 52,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                FaIcon(FontAwesomeIcons.userGraduate, size: 15.0,),
                                SizedBox(width: 10,),
                                Text(widget.currentUser.displayName, style: TextStyle(fontSize: 20.0),)
                              ],
                            ),
                            SizedBox(height: 20.0,),
                            Row(
                              children: <Widget>[
                                Icon(Icons.email, size: 15,),
                                SizedBox(width: 10,),
                                Text(widget.currentUser.email, style: TextStyle(fontSize: 14.0),)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

