import 'package:q_and_a/screens/shared_screens/user_instructions.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRoleWrapper extends StatefulWidget {

  final DocumentSnapshot userSnapshot;

  UserRoleWrapper({this.userSnapshot});

  @override
  _UserRoleWrapperState createState() => _UserRoleWrapperState();
}

class _UserRoleWrapperState extends State<UserRoleWrapper> {

  bool _isLoading = false;
  final DatabaseService databaseService = DatabaseService();

  _logInAsTeacher() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> userMap = {
      "displayName" : widget.userSnapshot.data['displayName'],
      "photoUrl" : widget.userSnapshot.data['photoUrl'],
      "email" : widget.userSnapshot.data['email'],
      "isAdmin" : true,
      "uid" : widget.userSnapshot.data['uid'],
    };
    await databaseService.addUserWithDetails(userData: userMap).then((val) {
      setState(() {
        _isLoading = false;
      });
    });

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => UserInstructions(isAdmin: true, displayName: widget.userSnapshot.data['displayName'],)
    ));



  }

  _logInAsStudent() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> userMap = {
      "displayName" : widget.userSnapshot.data['displayName'],
      "photoUrl" : widget.userSnapshot.data['photoUrl'],
      "email" : widget.userSnapshot.data['email'],
      "isAdmin" : false,
      "uid" : widget.userSnapshot.data['uid'],
    };
    await databaseService.addUserWithDetails(userData: userMap).then((val) {
      setState(() {
        _isLoading = false;
      });
    });

    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => UserInstructions(isAdmin: false, displayName: widget.userSnapshot.data['displayName'],)
    ));

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: _isLoading ? Loading() : Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: _logInAsTeacher,
              child: Container(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        "assets/images/teacher.jpg",
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.height / 2) - 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: (MediaQuery.of(context).size.height / 2) - 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black26,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("You are a", style: TextStyle(fontSize: 30.0, color: Colors.white),),
                          Text("Teacher", style: TextStyle(fontSize: 40.0, color: Colors.white),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _logInAsStudent,
              child: Container(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        "assets/images/student.jpg",
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.height / 2) - 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: (MediaQuery.of(context).size.height / 2) - 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black26,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("You are a", style: TextStyle(fontSize: 30.0, color: Colors.white),),
                          Text("Student", style: TextStyle(fontSize: 40.0, color: Colors.white),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}