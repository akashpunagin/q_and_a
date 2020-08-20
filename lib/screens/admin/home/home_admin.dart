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

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  String userId;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
        child: StreamBuilder(
          stream: databaseService.getQuizDetails(userId : userId),
          builder: (context, snapshots) {
            if (!snapshots.hasData) {
              return Loading();
            } else if (snapshots.data.documents.length == 0) {
              return InfoDisplay(
                textToDisplay: "Add Quiz to start",
              );
            } else {
             return ListView.builder(
                 itemCount: snapshots.data.documents.length,
                 itemBuilder: (context, index) {
                   QuizModel quizModel =  QuizModel(
                     imgURL: snapshots.data.documents[index].data["imgURL"],
                     topic: snapshots.data.documents[index].data["topic"],
                     description: snapshots.data.documents[index].data["description"],
                     quizId: snapshots.data.documents[index].data["quizId"],
                     nCorrect: 0,
                     nWrong: 0,
                   );

                   return QuizDetailsTile(
                     quizModel: quizModel,
                     teacherId: user.uid,
                     fromStudent: false,
                   );
                 }
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
              builder: (context) => CreateQuiz()
            )
          );
        },
      ),
    );
  }
}
