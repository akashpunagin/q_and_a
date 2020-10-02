import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/create_quiz/create_quiz.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/screens/shared_screens/quiz_details_tile.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/functions.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomeAdmin extends StatefulWidget {

  final TeacherModel currentUser;

  HomeAdmin({this.currentUser});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  List<String> _alerts = ["Your first quiz is uploaded. Now your students can view your quiz", "You can swipe on quiz to delete/edit quizzes"];
  String quizIdToDelete;
  bool _isLoading = false;

  displayDeleteQuizAlert(BuildContext context, QuizModel quizModel) {
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
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            Navigator.pop(context);

            // Delete images in cloud storage, of all questions in quiz
            await databaseService.getQuizQuestionDocuments(userId: widget.currentUser.uid, quizId: quizModel.quizId).then((value) {
              for(var document in value.docs) {
                deleteStorageImagesOfQuiz(
                  teacherId: widget.currentUser.uid,
                  quizId: quizModel.quizId,
                  questionId: document.data()['questionId'],
                  questionImageUrl: document.data()['questionImageUrl'],
                  option1ImageUrl: document.data()['option1ImageUrl'],
                  option2ImageUrl: document.data()['option2ImageUrl'],
                  option3ImageUrl: document.data()['option3ImageUrl'],
                  option4ImageUrl: document.data()['option4ImageUrl'],
                );
              }
              if(quizModel.imgURL != null) {
                // Delete quiz image in cloud storage
                ImageUploader imageUploader = ImageUploader();
                imageUploader.quizId = quizModel.quizId;
                imageUploader.userId = widget.currentUser.uid;
                imageUploader.field = "quizzes";
                imageUploader.isFromCreateQuiz = true;
                imageUploader.deleteUploaded();
              }
            });

            await databaseService.deleteQuizDetails(userId: widget.currentUser.uid, quizId: quizModel.quizId);
            setState(() {
              _isLoading = false;
            });
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
        child: StreamBuilder(
          stream: databaseService.getQuizDetails(userId : widget.currentUser.uid),
          builder: (context, snapshots) {
            if (!snapshots.hasData) {
              return Loading(
                loadingText: "Getting your quizzes",
              );
            } else if (snapshots.data.documents.length == 0) {
              return InfoDisplay(
                textToDisplay: "Add Quiz to start",
              );
            } else {
             return Column(
               children: [
                 snapshots.data.documents.length == 1 && widget.currentUser.isShowHomeAdminAlerts == true ? ListView.builder(
                     shrinkWrap: true,
                     itemCount: _alerts.length,
                     itemBuilder: (context, index) {
                       return Dismissible(
                         onDismissed: (direction) {
                           setState(() {
                             _alerts.removeAt(index);
                           });
                           if(_alerts.length == 0) {
                             widget.currentUser.isShowHomeAdminAlerts = false;
                           }
                         },
                         key: UniqueKey(),
                         child: screenLabel(
                           context: context,
                           child: ListTile(
                             title: Text(_alerts[index], textAlign: TextAlign.start,),
                             subtitle: Text("Swipe to dismiss", textAlign: TextAlign.end,),
                           ),
                         ),
                       );
                     }
                 ) : Container(),
                 AnimationConfiguration.synchronized(
                   child: FadeInAnimation(
                       duration: Duration(milliseconds: 400),
                       child: screenLabel(
                         context: context,
                         child: Text("My Quizzes", style: TextStyle(fontSize: 20, color: Colors.black54),),
                       )
                   ),
                 ),
                 SizedBox(height: 5,),
                 Expanded(
                   child: AnimationLimiter(
                     child: ListView.builder(
                         itemCount: snapshots.data.documents.length,
                         itemBuilder: (context, index) {
                           Map<String, dynamic> quizData = snapshots.data.documents[index].data();
                           QuizModel quizModel =  QuizModel(
                             imgURL: quizData["imgURL"],
                             topic: quizData["topic"],
                             description: quizData["description"],
                             quizId: quizData["quizId"],
                             nCorrect: 0,
                             nWrong: 0,
                           );

                           return AnimationConfiguration.staggeredList(
                             position: index,
                             duration: const Duration(milliseconds: 300),
                             child: SlideAnimation(
                               verticalOffset: 50.0,
                               duration: Duration(milliseconds: 200),
                               child: FadeInAnimation(
                                 duration: Duration(milliseconds: 300),
                                 child: Slidable(
                                   actionPane: SlidableDrawerActionPane(),
                                   closeOnScroll: true,
                                   actionExtentRatio: 0.25,
                                   child: _isLoading && quizModel.quizId == quizIdToDelete ? Card(
                                     margin: EdgeInsets.all(5),
                                     shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.all(Radius.circular(15))
                                     ),
                                     elevation: 5,
                                     child: Container(
                                       height: (MediaQuery.of(context).size.height / 3) - 50,
                                       width: MediaQuery.of(context).size.width,
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(15.0),
                                         color: Colors.black.withOpacity(0.7),
                                       ),
                                       alignment: Alignment.center,
                                       child: Loading(
                                         loadingText: "Deleting quiz - ${quizModel.topic}",
                                         textColor: Colors.white,
                                         spinKitColor: Colors.white,
                                       ),
                                     ),
                                   ): QuizDetailsTile(
                                     quizModel: quizModel,
                                     teacherId: widget.currentUser.uid,
                                     fromStudent: false,
                                   ),
                                   actions: <Widget>[
                                     SlideAction(
                                       child: screenLabel(
                                           context: context,
                                           child: Column(
                                             mainAxisAlignment: MainAxisAlignment.center,
                                             children: [
                                               Text("Delete"),
                                               Icon(Icons.delete),
                                             ],
                                           )
                                       ),
                                       onTap: () {
                                         setState(() {
                                           quizIdToDelete = quizModel.quizId;
                                         });
                                         displayDeleteQuizAlert(context, quizModel);
                                       },
                                     ),
                                     SlideAction(
                                       child: screenLabel(
                                         context: context,
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Text("Edit"),
                                             Icon(Icons.edit),
                                           ],
                                         )
                                       ),
                                       onTap: () {
                                         // todo edit quiz
                                       },
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           );
                         }
                     ),
                   ),
                 ),
               ],
             );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => CreateQuiz(currentUser: widget.currentUser,)
            )
          );
        },
      ),
    );
  }
}
