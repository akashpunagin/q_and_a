import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:q_and_a/screens/shared_screens/results_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:intl/intl.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentProgress extends StatefulWidget {

  final String userId;
  StudentProgress({this.userId});

  @override
  _StudentProgressState createState() => _StudentProgressState();
}

class _StudentProgressState extends State<StudentProgress> {

  DatabaseService databaseService = DatabaseService();
  final DateFormat formatterDate = DateFormat.MMMMd();
  final DateFormat formatterTime = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {


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
        child: FutureBuilder(
          future: databaseService.getStudentProgress(userId: widget.userId),
          builder: (context, future) {
            if(!future.hasData || future.connectionState == ConnectionState.waiting) {
              return Loading(loadingText: "Fetching your progress",);
            } else if(future.data.documents.length == 0) {
              return InfoDisplay(
                textToDisplay: "You've not submitted any quiz yet. Start submitting now!",
              );
            } else {
              return Column(
                children: [
                  Hero(
                    tag: "student_progress",
                    child: AnimationConfiguration.synchronized(
                      child: FadeInAnimation(
                          duration: Duration(milliseconds: 400),
                          child: bottomShadow(
                            child: Text("Your Progress", style: TextStyle(fontSize: 20.0, color: Colors.black54),),
                            context: context
                          )
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: future.data.documents.length,
                      itemBuilder: (context, index) {
                        final String formattedDate = formatterDate.format(future.data.documents[index].data()['createAt'].toDate());
                        final String formattedTime = formatterTime.format(future.data.documents[index].data()['createAt'].toDate());

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            horizontalOffset: MediaQuery.of(context).size.width,
                            duration: Duration(milliseconds: 400),
                            child: FadeInAnimation(
                              duration: Duration(milliseconds: 300),
                              child: ResultsTile(
                                index: (index+1).toString(),
                                date: "$formattedDate, $formattedTime",
                                teacherName: future.data.documents[index].data()['teacher'],
                                topic: future.data.documents[index].data()['topic'],
                                nTotal: future.data.documents[index].data()['nTotal'].toString(),
                                nCorrect: future.data.documents[index].data()['nCorrect'].toString(),
                                nWrong: future.data.documents[index].data()['nWrong'].toString(),
                                nNotAttempted: future.data.documents[index].data()['nNotAttempted'].toString(),
                              ),
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
