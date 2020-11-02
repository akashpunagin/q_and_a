import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/quiz_details_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:flutter/material.dart';
import 'package:q_and_a/shared/widgets.dart';

class HomeNotAdmin extends StatefulWidget {

  final StudentModel currentUser;
  HomeNotAdmin({this.currentUser});

  @override
  _HomeNotAdminState createState() => _HomeNotAdminState();
}

class _HomeNotAdminState extends State<HomeNotAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
      child: widget.currentUser.teacherEmail == null ? InfoDisplay(
        textToDisplay: "You have not selected your teacher yet",
      ) : Scaffold(
        body: StreamBuilder(
          stream: databaseService.getQuizDetails(userId : widget.currentUser.teacherId),
          builder: (context, snapshots) {
            if(snapshots.data == null) {
              return Loading(loadingText: "Getting quizzes",);
            } else if(snapshots.data.documents.length == 0) {
              return InfoDisplay(textToDisplay: "Wait for ${widget.currentUser.teacherName} to add quizzes",);
            } else {
              return Column(
                children: [
                  AnimationConfiguration.synchronized(
                    child: FadeInAnimation(
                        duration: Duration(milliseconds: 400),
                        child: screenLabel(
                          context: context,
                          child: Text("${widget.currentUser.teacherName}'s quizzes", style: TextStyle(fontSize: 18, color: Colors.black54),),
                        )
                    ),
                  ),
                  SizedBox(height: 5,),
                  Expanded(
                    child: ListView.builder(
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
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 300),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              duration: Duration(milliseconds: 200),
                              child: FadeInAnimation(
                                  duration: Duration(milliseconds: 300),
                                  child: QuizDetailsTile(
                                    quizModel: quizModel,
                                    teacherId: widget.currentUser.teacherId,
                                    fromStudent: true,
                                  )
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
