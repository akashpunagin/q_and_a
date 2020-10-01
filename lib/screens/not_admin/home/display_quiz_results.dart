import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/material.dart';
import '../not_admin.dart';

class DisplayQuizResults extends StatelessWidget {

  final int nCorrect;
  final int nWrong;
  final int nNotAttempted;
  final int total;
  final String topic;

  DisplayQuizResults({this.nCorrect, this.nWrong, this.nNotAttempted, this.topic, this.total});

  @override
  Widget build(BuildContext context) {

    String notAttemptedText = "";
    if(nNotAttempted > 0) {
      if (nNotAttempted == 1) {
        notAttemptedText = "$nNotAttempted was not attempted.";
      } else {
        notAttemptedText = "$nNotAttempted were not attempted.";
      }
    } else {
      notAttemptedText = "every question was attempted.";
    }

    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("For quiz on \"$topic\", you've scored", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
            SizedBox(height: 5.0,),
            Text("$nCorrect correct and $nWrong wrong.", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
            SizedBox(height: 5.0,),
            Text("There were $total total questions, out of those,", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
            SizedBox(height: 5.0,),
            Text(notAttemptedText, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
            SizedBox(height: 40.0,),
            blueButton(context: context, label: "Go To Home", onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => NotAdmin()
              ));
            }),
          ],
        ),
      ),
    );

  }
}
