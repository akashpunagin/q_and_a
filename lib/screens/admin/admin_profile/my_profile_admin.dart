import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/admin_profile/quiz_submissions.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:q_and_a/shared/widgets.dart';

class MyProfileAdmin extends StatefulWidget {

  @override
  _MyProfileAdminState createState() => _MyProfileAdminState();
}

class _MyProfileAdminState extends State<MyProfileAdmin> {

  DatabaseService databaseService = DatabaseService();
  String teacherId;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);
    Future<Map<String, dynamic>> mapData;
    if (user != null) {
      DocumentReference result = databaseService.getUserWithUserId(user.uid);
      mapData = result.get().then((result){

        // setState(() {
          teacherId = result.data()["uid"];
        // });

        return {
          "displayName" : result.data()['displayName'],
          "email" : result.data()['email'],
          "photoURL" : result.data()['photoUrl'],
        };
      });
    }

    return Scaffold(
      body: FutureBuilder(
        future: mapData,
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Loading(loadingText: "Just a moment",);
          } else {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            "My Profile",
                            style: TextStyle(fontSize: 35.0, color: Colors.black54),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  future.data['photoURL'],
                                ),
                                radius: 60,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 18.0,),
                                      SizedBox(width: 10,),
                                      Text(future.data['displayName'], style: TextStyle(fontSize: 20.0),),
                                    ],
                                  ),
                                  SizedBox(height: 15,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.email, size: 20.0,),
                                      SizedBox(width: 20,),
                                      Column(
                                        children: [
                                          Text(future.data['email'].toString().split("@")[0], style: TextStyle(fontSize: 20.0, color: Colors.black),),
                                          Text("@${future.data['email'].toString().split("@")[1]}", style: TextStyle(fontSize: 15.0, color: Colors.black54),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          blueButton(
                            context: context,
                            label: "View Quiz Submissions",
                            onPressed: () {
                              // print("## $teacherId");
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => QuizSubmissions(teacherId: teacherId,)
                              ));
                            },
                          ),
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
        },
      ),
    );
  }
}
