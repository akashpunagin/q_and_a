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
import 'package:q_and_a/shared/widgets.dart';

class HomeAdmin extends StatefulWidget {

  final UserModel currentUser;

  HomeAdmin({this.currentUser});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();

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
                                 child: QuizDetailsTile(
                                   quizModel: quizModel,
                                   teacherId: widget.currentUser.uid,
                                   fromStudent: false,
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
