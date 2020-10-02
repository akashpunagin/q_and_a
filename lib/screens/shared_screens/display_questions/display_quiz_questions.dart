import 'package:cached_network_image/cached_network_image.dart';
import 'package:q_and_a/models/question_model.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/create_quiz/add_question.dart';
import 'package:q_and_a/screens/not_admin/home/display_quiz_results.dart';
import 'package:q_and_a/screens/not_admin/not_admin.dart';
import 'package:q_and_a/screens/shared_screens/display_questions/question_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/send_email.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DisplayQuizQuestions extends StatefulWidget {

  final String quizId;
  final String teacherId;
  final QuizModel quizModel;
  final bool fromStudent;
  DisplayQuizQuestions({this.quizId, this.teacherId, this.quizModel, this.fromStudent});

  @override
  _DisplayQuizQuestionsState createState() => _DisplayQuizQuestionsState();
}

class _DisplayQuizQuestionsState extends State<DisplayQuizQuestions> {

  DatabaseService databaseService = new DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> _alerts = ["Once you submit the quiz, an email will be sent to your teacher about your progress", "Note that for each question, you can select your answer only once.\nAll the best!"];

  Question _getQuestionModelFromStream(DocumentSnapshot questionSnapshot) {
    Question questionModel = new Question();

    questionModel.question = questionSnapshot.data()["question"];
    questionModel.option1 = questionSnapshot.data()["option1"];
    questionModel.option2 = questionSnapshot.data()["option2"];
    questionModel.option3 = questionSnapshot.data()["option3"];
    questionModel.option4 = questionSnapshot.data()["option4"];
    questionModel.correctOption = questionSnapshot.data()["option1"];
    questionModel.questionId = questionSnapshot.data()["questionId"];
    questionModel.isTrueOrFalseType = questionSnapshot.data()["isTrueOrFalseType"];
    questionModel.trueOrFalseAnswer = questionSnapshot.data()["trueOrFalseAnswer"];
    questionModel.questionImageUrl = questionSnapshot.data()['questionImageUrl'];
    questionModel.option1ImageUrl = questionSnapshot.data()['option1ImageUrl'];
    questionModel.option2ImageUrl = questionSnapshot.data()['option2ImageUrl'];
    questionModel.option3ImageUrl = questionSnapshot.data()['option3ImageUrl'];
    questionModel.option4ImageUrl = questionSnapshot.data()['option4ImageUrl'];
    questionModel.questionImageCaption = questionSnapshot.data()['questionImageCaption'];
    questionModel.option1ImageCaption = questionSnapshot.data()['option1ImageCaption'];
    questionModel.option2ImageCaption = questionSnapshot.data()['option2ImageCaption'];
    questionModel.option3ImageCaption = questionSnapshot.data()['option3ImageCaption'];
    questionModel.option4ImageCaption = questionSnapshot.data()['option4ImageCaption'];
    questionModel.isAnswered = false;

    return questionModel;

  }

  _submitQuiz(UserModel user) async {

    DocumentReference result = databaseService.getUserWithUserId(user.uid);
    Map<String, String> teacherData = await result.get().then((result){
      return {
        "teacherEmail" : result.data()['teacherEmail'],
        "displayName" : result.data()['displayName'],
      };
    });

    databaseService.updateStudentTotals(
      userId: user.uid,
      nCorrect: widget.quizModel.nCorrect,
      nWrong: widget.quizModel.nWrong,
      nNotAttempted: widget.quizModel.nNotAttempted,
    );

    Map<String, dynamic> progressData = {
      "teacher" : teacherData['teacherEmail'],
      "nCorrect" : widget.quizModel.nCorrect,
      "nWrong" : widget.quizModel.nWrong,
      "nNotAttempted" : widget.quizModel.nNotAttempted,
      "topic" : widget.quizModel.topic,
      "nTotal" : widget.quizModel.nTotal,
      "createAt" : Timestamp.now(),
    };
    databaseService.addStudentProgress(
      userId: user.uid,
      progressData: progressData,
    );

    SendEmail sendEmail = SendEmail();

    sendEmail.teacherEmail = teacherData['teacherEmail'];
    sendEmail.studentName = teacherData['displayName'];
    sendEmail.topic = widget.quizModel.topic;
    sendEmail.nWrong = widget.quizModel.nWrong;
    sendEmail.nCorrect = widget.quizModel.nCorrect;
    sendEmail.nTotal = widget.quizModel.nTotal;
    sendEmail.nNotAttempted = widget.quizModel.nNotAttempted;

    await sendEmail.sendEmailQuizSubmit();

    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => DisplayQuizResults(
          nCorrect: widget.quizModel.nCorrect,
          nWrong: widget.quizModel.nWrong,
          nNotAttempted: widget.quizModel.nNotAttempted,
          total: widget.quizModel.nTotal,
          topic: widget.quizModel.topic,
        )
    ));
  }

  setDisplayQuestionsState() {
    setState(() { });
  }

  showEditedSnackBar(int index) {
    final snackBar = SnackBar(
      content: Text("Q${(index+1).toString()} was edited successfully", style: TextStyle(fontSize: 15.0),),
      backgroundColor: Colors.blueAccent,
    );
    _scaffoldKey.currentState.removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    _scaffoldKey.currentState.showSnackBar(snackBar);

  }
  @override
  void initState() {
    super.initState();
    widget.quizModel.nTotal = 0;
    widget.quizModel.nNotAttempted = 0;
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Colors.blue
        ),
        actions: <Widget>[
          widget.fromStudent == true ? FlatButton.icon(
            onPressed: () {

              Map<String, dynamic> quizResult = {
                "student" : user.displayName,
                "nCorrect" : widget.quizModel.nCorrect,
                "nWrong" : widget.quizModel.nWrong,
                "nNotAttempted" : widget.quizModel.nNotAttempted,
                "topic" : widget.quizModel.topic,
                "nTotal" : widget.quizModel.nTotal,
                "createAt" : Timestamp.now(),
              };
              databaseService.addQuizSubmissionDetails(
                teacherId: widget.teacherId,
                quizResultData: quizResult,
              ).then((value) {
                displaySelectGmailAlert(context: context, onPressed: () {
                  _submitQuiz(user);
                });
              }).catchError((err) {
                print("ERROR $err");
              });
            },
            label: Text("Submit", style: TextStyle(fontSize: 17, color: Colors.black87),),
            icon: FaIcon(FontAwesomeIcons.shareSquare, size: 17.0,),
          ) :
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddQuestion(
                    quizId: widget.quizModel.quizId,
                    quizTopic: widget.quizModel.topic,
                  )
              ));
            },
            icon: FaIcon(FontAwesomeIcons.plus, size: 17.0,),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: user.uid != widget.teacherId ?
        databaseService.getQuizQuestionDetails(quizId : widget.quizModel.quizId, userId : widget.teacherId) :
        databaseService.getQuizQuestionDetails(quizId : widget.quizModel.quizId, userId : user.uid),
        builder: (context, snapshots) {
          if(snapshots.data == null) {
            return Loading(loadingText: "Just a moment, wait for questions to load from '${widget.quizModel.topic}'",);
          } else if(snapshots.data.documents.length == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InfoDisplay(textToDisplay:
                widget.fromStudent ? "Wait for your teacher to add questions in this quiz" : "You haven't added any questions yet, add them now!",
                ),
                SizedBox(height: 10,),
                widget.fromStudent ? blueButton(
                    width: MediaQuery.of(context).size.width - 40,
                    label: "Go Back",
                    context: context,
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => NotAdmin()
                      ));
                    }
                ) : Container(),
              ],
            );
          } else {
            return Column(
              children: <Widget>[
                widget.fromStudent == true ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // todo remove this function and hard code
                      listDismissibleAlerts(alerts: _alerts, onDismissed: () {}),
                    ],
                  ),
                ) : Container(),
                Hero(
                  tag: widget.quizModel.quizId,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        child: Text("Topic : ${widget.quizModel.topic}", style: TextStyle(fontSize: 16.0, color: Colors.black54), textAlign: TextAlign.center, overflow: TextOverflow.fade,),
                      ),
                    ),
                  )
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshots.data.documents.length,
                      itemBuilder: (context, index) {
                        widget.quizModel.nTotal = snapshots.data.documents.length;
                        widget.quizModel.nNotAttempted = snapshots.data.documents.length;
                        return Column(
                          children: [
                            QuestionTile(
                              questionModel: _getQuestionModelFromStream(snapshots.data.documents[index]),
                              index: index,
                              quizModel: widget.quizModel,
                              fromStudent: widget.fromStudent,
                              teacherId: widget.teacherId,
                              setDisplayQuestionsState: setDisplayQuestionsState,
                              showEditSnackBar: showEditedSnackBar,
                            ),
                          ],
                        );
                      }
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
