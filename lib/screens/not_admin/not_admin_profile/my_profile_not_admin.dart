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

  totalDisplayTile({String label, String value}) {
    return Card(
      elevation: 3,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 15),),
            Text(value, style: TextStyle(fontSize: 20),),
          ],
        ),
      ),
    );
  }

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
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("My Profile",style: TextStyle(fontSize: 30.0, color: Colors.black54),),
                    GridView.count(
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      padding: EdgeInsets.zero,
                      childAspectRatio: 16/7,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: [
                        totalDisplayTile(label: "Correct Answers", value: widget.currentUser.nTotalCorrect.toString()),
                        totalDisplayTile(label: "Wrong Answers", value: widget.currentUser.nTotalWrong.toString()),
                        totalDisplayTile(label: "Not Attempted", value: widget.currentUser.nTotalNotAttempted.toString()),
                        totalDisplayTile(label: "Total Submissions", value: widget.currentUser.nTotalQuizSubmitted.toString()),
                      ],
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     totalDisplayTile(label: "Correct Answers", value: widget.currentUser.nTotalCorrect.toString()),
                    //     totalDisplayTile(label: "Wrong Answers", value: widget.currentUser.nTotalWrong.toString()),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     totalDisplayTile(label: "Not Attempted", value: widget.currentUser.nTotalNotAttempted.toString()),
                    //     totalDisplayTile(label: "Total Quiz Submitted", value: widget.currentUser.nTotalQuizSubmitted.toString()),
                    //   ],
                    // ),

                    // Text("Correct Answers : ${widget.currentUser.nTotalCorrect}", style: TextStyle(fontSize: 18),),
                    // Text("Wrong Answers : ${widget.currentUser.nTotalWrong}", style: TextStyle(fontSize: 18),),
                    // Text("Not Attempted : ${widget.currentUser.nTotalNotAttempted}", style: TextStyle(fontSize: 18),),
                    // Text("Total Quiz Submitted : ${widget.currentUser.nTotalQuizSubmitted}", style: TextStyle(fontSize: 18),),
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
                                Column(
                                  children: [
                                    Text(widget.currentUser.email.toString().split("@")[0], style: TextStyle(fontSize: 14.0),),
                                    Text(widget.currentUser.email.toString().split("@")[1], style: TextStyle(fontSize: 14.0),),
                                  ],
                                )
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

