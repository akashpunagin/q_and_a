import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/admin.dart';
import 'package:q_and_a/screens/admin/admin_profile/quiz_submissions.dart';
import 'package:q_and_a/screens/not_admin/not_admin.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/screens/sign_up_google.dart';
import 'package:q_and_a/screens/user_role_wrapper.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Wrapper extends StatefulWidget {

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final DatabaseService databaseService = DatabaseService();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<String> _getDeviceToken() async {
     return await _firebaseMessaging.getToken();
  }

  _showNotificationAlert({BuildContext context, String title, String desc, String subject, String teacherId}) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: title,
      desc: desc,
      buttons: subject == null ? [
        DialogButton(
          child: Text(
            "Okay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          width: 120,
        ),
      ] : [
        DialogButton(
          child: Text(
            "Open",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (subject!= null && subject == "new_quiz_submission") {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QuizSubmissions(teacherId: teacherId)
              )).then((value) {
                Navigator.of(context).pop();
              });
            }
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            "Okay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          width: 120,
        ),
      ],
    ).show();
  }

  _configureFirebaseMessaging(BuildContext context) async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _showNotificationAlert(
          context: context,
          title: message['notification']['title'],
          desc: message['notification']['body'],
          subject: message['data']['subject'] ?? null,
          teacherId: message['data']['teacherId'] ?? null,
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
      },
      onResume: (Map<String, dynamic> message) async {
      },
    );
  }

  setWrapperState() {
    setState(() { });
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _configureFirebaseMessaging(context);
    final user = Provider.of<UserModel>(context);

    if (user == null){
      return SignUpGoogle(setWrapperState: setWrapperState,);
    } else {
      DocumentReference result = databaseService.getUserWithUserId(user.uid);
      Future<StatefulWidget> widget = result.get().then((result){
        _getDeviceToken().then((value) {
          databaseService.updateUserDeviceToken(userId: result.data()['uid'], deviceToken: value);
        });
        if (result.data().containsKey("isAdmin")) {
          if (result.data()['isAdmin']) {
            _firebaseMessaging.subscribeToTopic('teacher');
            return Admin();
          } else {
            _firebaseMessaging.subscribeToTopic('student');
            return NotAdmin();
          }
        } else {
          return UserRoleWrapper(userSnapshot: result);
        }
      });

      return FutureBuilder(
        future: widget,
        builder: (context, future) {
          if(future.connectionState == ConnectionState.waiting || !future.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                brightness: Brightness.light,
                title: appBar(context),
                elevation: 0.0,
              ),
              body:Loading(
                loadingText: "Just a moment",
              ),
            );
          } else {
            return future.data;
          }
        },
      );
    }
  }
}