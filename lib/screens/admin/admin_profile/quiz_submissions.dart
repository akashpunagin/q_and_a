import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/screens/shared_screens/results_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:intl/intl.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/material.dart';

class QuizSubmissions extends StatefulWidget {

  final String teacherId;
  QuizSubmissions({this.teacherId});

  @override
  _QuizSubmissionsState createState() => _QuizSubmissionsState();
}

class _QuizSubmissionsState extends State<QuizSubmissions> {

  DatabaseService databaseService = DatabaseService();
  final DateFormat formatterDate = DateFormat.MMMMd();
  final DateFormat formatterTime = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {

    // Future<QuerySnapshot> result = databaseService.getStudentProgress(userId: widget.teacherId);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        title: appBar(context),
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Colors.black54
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: StreamBuilder(
          stream: databaseService.getQuizSubmissionDetails(teacherId: widget.teacherId),
          builder: (context, snapshots) {
            if(!snapshots.hasData || snapshots.connectionState == ConnectionState.waiting) {
              return Loading(loadingText: "Fetching your progress",);
            } else if(snapshots.data.documents.length == 0) {
              return InfoDisplay(
                textToDisplay: "You've not received any quiz submissions yet",
              );
            } else {
              return Column(
                children: [
                  Hero(
                    tag: "quiz_submissions",
                    child: AnimationConfiguration.synchronized(
                      child: FadeInAnimation(
                          duration: Duration(milliseconds: 400),
                          child: bottomShadow(
                            child: Text("My Quiz Submissions", style: TextStyle(fontSize: 20.0, color: Colors.black54),),
                            context: context
                          )
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: snapshots.data.documents.length,
                        itemBuilder: (context, index) {
                          final String formattedDate = formatterDate.format(snapshots.data.documents[index].data()['createAt'].toDate());
                          final String formattedTime = formatterTime.format(snapshots.data.documents[index].data()['createAt'].toDate());
                          
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 300),
                            child: SlideAnimation(
                              verticalOffset: 20.0,
                              child: FadeInAnimation(
                                duration: Duration(milliseconds: 400),
                                child: ResultsTile(
                                  index: (index+1).toString(),
                                  date: "$formattedDate, $formattedTime",
                                  teacherName: snapshots.data.documents[index].data()['student'],
                                  topic: snapshots.data.documents[index].data()['topic'],
                                  nTotal: snapshots.data.documents[index].data()['nTotal'].toString(),
                                  nCorrect: snapshots.data.documents[index].data()['nCorrect'].toString(),
                                  nWrong: snapshots.data.documents[index].data()['nWrong'].toString(),
                                  nNotAttempted: snapshots.data.documents[index].data()['nNotAttempted'].toString(),
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
    );
  }
}
