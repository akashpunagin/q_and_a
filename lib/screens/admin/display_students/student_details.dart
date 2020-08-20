import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/display_students/students_details_tile.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDetails extends StatefulWidget {

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {

  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    DocumentReference result = databaseService.getUserWithUserId(user.uid);
    Future<String> email = result.get().then((result){
      if ( result.data.containsKey("email") ) {
        return result.data['email'];
      } else {
        return null;
      }
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20.0),
      child: FutureBuilder(
        future: email,
        builder: (context, future) {
          return future.data == null ? Loading() : StreamBuilder(
            stream: databaseService.getUserWithField(
                fieldKey: "teacherEmail",
                fieldValue: future.data,
                limit: null),
            builder: (context, snapshots) {
              if( !snapshots.hasData) {
                return Loading();
              } else if (snapshots.data.documents.length == 0) {
                return InfoDisplay(
                  textToDisplay: "You don't have any students as of now",
                );
              } else {
                return SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Text("Your Students", style: TextStyle(fontSize: 20.0),),
                      SizedBox(height: 10.0,),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshots.data.documents.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: StudentDetailsTile(
                                displayName: snapshots.data.documents[index].data["displayName"],
                                email: snapshots.data.documents[index].data["email"],
                                photoUrl: snapshots.data.documents[index].data["photoUrl"],
                              ),
                            );
                          }
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
