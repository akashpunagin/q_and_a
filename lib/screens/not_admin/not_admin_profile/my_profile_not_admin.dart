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

  MyProfileNotAdmin({Key key}) : super(key: key);

  @override
  _MyProfileNotAdminState createState() => _MyProfileNotAdminState();
}

class _MyProfileNotAdminState extends State<MyProfileNotAdmin> {

  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);
    Future<Map<String, dynamic>> mapData;
    if (user != null) {
      DocumentReference result = databaseService.getUserWithUserId(user.uid);
      mapData = result.get().then((result){
        return {
          "displayName" : result.data()['displayName'],
          "email" : result.data()['email'],
          "photoURL" : result.data()['photoUrl'],
          "nTotalCorrect" : result.data().containsKey("nTotalCorrect") ? result.data()['nTotalCorrect'] : 0,
          "nTotalWrong" : result.data().containsKey("nTotalWrong") ? result.data()['nTotalWrong'] : 0,
          "nTotalNotAttempted" : result.data().containsKey("nTotalNotAttempted") ? result.data()['nTotalNotAttempted'] : 0,
          "nTotalQuizSubmitted" : result.data().containsKey("nTotalQuizSubmitted") ? result.data()['nTotalQuizSubmitted'] : 0,
        };
      });
    }

    return Scaffold(
      body: FutureBuilder(
        future: mapData,
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Loading(loadingText: "Just a moment");
          } else {
            return Container(
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
                          Text("My Profile",style: TextStyle(fontSize: 40.0,),),
                          Text("Correct Answers : ${future.data['nTotalCorrect']}", style: TextStyle(fontSize: 18),),
                          Text("Wrong Answers : ${future.data['nTotalWrong']}", style: TextStyle(fontSize: 18),),
                          Text("Not Attempted : ${future.data['nTotalNotAttempted']}", style: TextStyle(fontSize: 18),),
                          Text("Total Quiz Submitted : ${future.data['nTotalQuizSubmitted']}", style: TextStyle(fontSize: 18),),
                          blueButton(context: context, label: "View your progress", onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => StudentProgress(userId: user.uid,)
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
                                  future.data['photoURL'],
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
                                      Text(future.data['displayName'], style: TextStyle(fontSize: 20.0),)
                                    ],
                                  ),
                                  SizedBox(height: 20.0,),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.email, size: 15,),
                                      SizedBox(width: 10,),
                                      Text(future.data['email'], style: TextStyle(fontSize: 14.0),)
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
            );
          }
        },
      ),
    );
  }
}

