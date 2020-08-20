import 'package:q_and_a/screens/admin/admin.dart';
import 'package:q_and_a/screens/not_admin/not_admin.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UserInstructions extends StatefulWidget {

  final bool isAdmin;
  final String displayName;
  UserInstructions({this.isAdmin, this.displayName});

  @override
  _UserInstructionsState createState() => _UserInstructionsState();
}

class _UserInstructionsState extends State<UserInstructions> {

  List<String> studentInstructions = [
    "This app let's teachers and students login with different accounts, you have logged in as Student",
    "You should select your teacher by editing your teacher email to display all the quizzes posted by them",
    "After attending a particular quiz, you should submit the results to your teacher",
    "You can also see your progress in QandA and share it with the selected teacher",
    "If you logout, the app will automatically sign you in as student the next time you log in",
    "If you have any queries, you can contact *akash.punagin@gmail.com*",
  ];

  List<String> teacherInstructions = [
    "This app let's teachers and students login with different accounts, you have logged in as Teacher",
    "You don't have to select your students. The students will select the teacher",
    "You can post various quizzes for your students, containing any number of questions, each with 4 options",
    "You can view all the students who currently have selected you as their teacher and if any of them submits your quiz, an E-mail will be sent to you with attached PDF",
    "Your students can also share their progress in QandA with you. You will receive an E-mail with attached PDF detailing all the quizzes they have submitted with their scores and time of day",
    "If you logout, the app will automatically sign you in as teacher the next time you log in",
    "If you have any queries, you can contact *akash.punagin@gmail.com*",
  ];

  @override
  Widget build(BuildContext context) {

    final text = widget.isAdmin ? teacherInstructions.map((x) => "- $x\n").reduce((x, y) => "$x$y")
        : studentInstructions.map((x) => "- $x\n").reduce((x, y) => "$x$y");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        title: appBar(context),
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            Text("Instructions for you, ${widget.displayName}", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
            SizedBox(height: 20,),
            Expanded(
              child: MarkdownBody(
                data: text,
              ),
            ),
            blueButton(context: context, label: "Continue", onPressed: (){
              if(widget.isAdmin) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Admin()
                ));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => NotAdmin()
                ));
              }
            }),
          ],
        ),
      ),
    );
  }
}
