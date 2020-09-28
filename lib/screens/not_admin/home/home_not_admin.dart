import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/quiz_details_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeNotAdmin extends StatefulWidget {

  final StudentModel currentUser;
  HomeNotAdmin({this.currentUser});

  @override
  _HomeNotAdminState createState() => _HomeNotAdminState();
}

class _HomeNotAdminState extends State<HomeNotAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  static String teacherId;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
      child: widget.currentUser.teacherEmail == null ? InfoDisplay(
        textToDisplay: "You have not selected your teacher yet",
      ) : Scaffold(
        body: StreamBuilder(
          stream: databaseService.getUserWithField(
              fieldKey: "email",
              fieldValue: widget.currentUser.teacherEmail,
              limit: null),
          builder: (context, snapshots) {
            try{
              teacherId = snapshots.hasData ? snapshots.data.documents[0].data()['uid'] : null;
              return StreamBuilder(
                stream: databaseService.getQuizDetails(userId : teacherId),
                builder: (context, snapshots) {
                  return snapshots.data == null ? Loading(loadingText: "Getting quizzes",) : ListView.builder(
                      itemCount: snapshots.data.documents.length,
                      itemBuilder: (context, index) {
                        QuizModel quizModel =  QuizModel(
                          imgURL: snapshots.data.documents[index].data()["imgURL"],
                          topic: snapshots.data.documents[index].data()["topic"],
                          description: snapshots.data.documents[index].data()["description"],
                          quizId: snapshots.data.documents[index].data()["quizId"],
                          nCorrect: 0,
                          nWrong: 0,
                        );

                        return QuizDetailsTile(
                          quizModel: quizModel,
                          teacherId: teacherId,
                          fromStudent: true,
                        );
                      }
                  );
                },
              );
            } catch (e) {
              return InfoDisplay(
                textToDisplay: "Email \"${widget.currentUser.teacherEmail}\" not found.\nUpdate your teacher email.",
              );
            }
          },
        ),
      ),
    );
  }
}
