import 'dart:io';

import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/screens/shared_screens/display_questions/display_quiz_questions.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuizDetailsTile extends StatelessWidget {

  final DatabaseService databaseService = DatabaseService();

  final String teacherId;
  final QuizModel quizModel;
  final bool fromStudent;
  final bool fromCreateQuiz;
  final File quizImage;
  QuizDetailsTile({this.teacherId, this.quizModel, this.fromStudent, this.fromCreateQuiz, this.quizImage});

  displayDeleteQuizAlert(BuildContext context) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: "Quiz Deletion",
      desc: "Are you you want to delete\nQuiz - ${quizModel.topic}?",
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            databaseService.deleteQuizDetails(userId: teacherId, quizId: quizModel.quizId);
          },
          gradient: LinearGradient(colors: [
            Colors.blue[500],
            Colors.blue[400],
          ]),
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Colors.blue[400],
            Colors.blue[500],
          ]),
        )
      ],
    ).show();
  }

  displayTimerAlert(BuildContext context) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: "E-mail alert",
      desc: "Once you submit the quiz, an E-mail will be sent to your teacher about your progress. Are you sure you are ready?",
      buttons: [
        DialogButton(
          child: Text(
            "I'm ready",
            style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: -1),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => DisplayQuizQuestions(quizId: quizModel.quizId, teacherId: teacherId, quizModel: quizModel, fromStudent: true,)
            ));
          },
          gradient: LinearGradient(colors: [
            Colors.blue[500],
            Colors.blue[400],
          ]),
        ),
        DialogButton(
          child: Text(
            "I'm not ready",
            style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: -1),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Colors.blue[400],
            Colors.blue[500],
          ]),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (fromStudent == true) {
          displayTimerAlert(context);
        } else {
          if(fromCreateQuiz != true) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => DisplayQuizQuestions(
                  quizId: quizModel.quizId,
                  teacherId: teacherId,
                  quizModel: quizModel,
                  fromStudent: false,
                )
            ));
          }
        }
      },
      onLongPress: () {
        if(fromStudent != true) {
          displayDeleteQuizAlert(context);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5,),
        height: (MediaQuery.of(context).size.height / 3) - 50,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: fromCreateQuiz == true  && quizImage != null ? Container(
                width: MediaQuery.of(context).size.width - 20,
                child: Image.file(
                  quizImage,
                  fit: BoxFit.cover,
                ),
              ) : CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                useOldImageOnUrlChange: false,
                imageUrl: quizModel.imgURL == "" || quizModel.imgURL == null ? defaultQuizImageURL : quizModel.imgURL,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 20,
                    child: Image(
                      fit: BoxFit.cover,
                      image: imageProvider,
                    ),
                  );
                },
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, e) => Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.topCenter,
                  child: Text("Enter Correct Image URL", style: TextStyle(fontSize: 18),),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black45,
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(quizModel.topic, style: TextStyle(fontSize: 25.0, color: Colors.white), textAlign: TextAlign.center, overflow: TextOverflow.fade,),
                    SizedBox(height: 10,),
                    Text(quizModel.description,
                      style: TextStyle(fontSize: 20.0, color: Colors.white), textAlign: TextAlign.center, overflow: TextOverflow.fade,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
