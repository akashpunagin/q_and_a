import 'dart:io';

import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/screens/shared_screens/display_questions/display_quiz_questions.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:q_and_a/shared/functions.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class QuizDetailsTile extends StatefulWidget {

  final String teacherId;
  final QuizModel quizModel;
  final bool fromStudent;
  final bool fromCreateQuiz;
  final File quizImage;
  QuizDetailsTile({this.teacherId, this.quizModel, this.fromStudent, this.fromCreateQuiz, this.quizImage});

  @override
  _QuizDetailsTileState createState() => _QuizDetailsTileState();
}

class _QuizDetailsTileState extends State<QuizDetailsTile> {
  final DatabaseService databaseService = DatabaseService();
  bool _isLoading = false;

  displayDeleteQuizAlert(BuildContext context) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: "Quiz Deletion",
      desc: "Are you you want to delete\nQuiz - ${widget.quizModel.topic}?",
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            Navigator.pop(context);

            // Delete images in cloud storage, of all questions in quiz
            await databaseService.getQuizQuestionDocuments(userId: widget.teacherId, quizId: widget.quizModel.quizId).then((value) {
              for(var document in value.docs) {
                deleteStorageImagesOfQuiz(
                  teacherId: widget.teacherId,
                  quizId: widget.quizModel.quizId,
                  questionId: document.data()['questionId'],
                  questionImageUrl: document.data()['questionImageUrl'],
                  option1ImageUrl: document.data()['option1ImageUrl'],
                  option2ImageUrl: document.data()['option2ImageUrl'],
                  option3ImageUrl: document.data()['option3ImageUrl'],
                  option4ImageUrl: document.data()['option4ImageUrl'],
                );
              }
              if(widget.quizModel.imgURL != null) {
                // Delete quiz image in cloud storage
                ImageUploader imageUploader = ImageUploader();
                imageUploader.quizId = widget.quizModel.quizId;
                imageUploader.userId = widget.teacherId;
                imageUploader.field = "quizzes";
                imageUploader.isFromCreateQuiz = true;
                imageUploader.deleteUploaded();
                print("DELETED QUIZ");
              }
            });
            await databaseService.deleteQuizDetails(userId: widget.teacherId, quizId: widget.quizModel.quizId);
            setState(() {
              _isLoading = false;
            });
            // Navigator.pop(context);
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

  displayMailSendAlert(BuildContext context) {
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
                builder: (context) => DisplayQuizQuestions(
                  quizId: widget.quizModel.quizId,
                  teacherId: widget.teacherId,
                  quizModel: widget.quizModel,
                  fromStudent: true,
                )
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
        if (widget.fromStudent == true) {
          displayMailSendAlert(context);
        } else {
          if(widget.fromCreateQuiz != true) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => DisplayQuizQuestions(
                  quizId: widget.quizModel.quizId,
                  teacherId: widget.teacherId,
                  quizModel: widget.quizModel,
                  fromStudent: false,
                )
            ));
          }
        }
      },
      onLongPress: () {
        if(widget.fromStudent != true) {
          displayDeleteQuizAlert(context);
        }
      },
      child: Card(
        margin: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        elevation: 5,
        child: Container(
          height: (MediaQuery.of(context).size.height / 3) - 50,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: widget.fromCreateQuiz == true  && widget.quizImage != null ? Container(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Image.file(
                    widget.quizImage,
                    fit: BoxFit.cover,
                  ),
                ) : CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: false,
                  imageUrl: widget.quizModel.imgURL == "" || widget.quizModel.imgURL == null ? defaultQuizImageURL : widget.quizModel.imgURL,
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
              _isLoading ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black.withOpacity(0.7),
                ),
                alignment: Alignment.center,
                child: Loading(
                  loadingText: "Deleting",
                  textColor: Colors.white,
                  spinKitColor: Colors.white,
                ),
              ) : Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black45,
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.quizModel.topic, style: TextStyle(fontSize: 25.0, color: Colors.white), textAlign: TextAlign.center, overflow: TextOverflow.fade,),
                      SizedBox(height: 10,),
                      Text(widget.quizModel.description,
                        style: TextStyle(fontSize: 20.0, color: Colors.white), textAlign: TextAlign.center, overflow: TextOverflow.fade,),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}