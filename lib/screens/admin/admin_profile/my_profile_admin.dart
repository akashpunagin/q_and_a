import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyProfileAdmin extends StatefulWidget {

  @override
  _MyProfileAdminState createState() => _MyProfileAdminState();
}

class _MyProfileAdminState extends State<MyProfileAdmin> {

  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    Future<Map<String, dynamic>> mapData;
    if (user != null) {
      DocumentReference result = databaseService.getUserWithUserId(user.uid);
      mapData = result.get().then((result){
        return {
          "displayName" : result.data['displayName'],
          "email" : result.data['email'],
          "photoURL" : result.data['photoUrl'],
        };
      });
    }

    return Scaffold(
      body: FutureBuilder(
        future: mapData,
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            return Container(
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
                            style: TextStyle(
                              fontSize: 35.0,
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              future.data['photoURL'],
                            ),
                            radius: 60,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20.0,),
                              SizedBox(width: 10,),
                              Text(future.data['displayName'], style: TextStyle(fontSize: 25.0),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.email),
                              SizedBox(width: 10,),
                              Text(future.data['email'], style: TextStyle(fontSize: 20.0),)
                            ],
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
