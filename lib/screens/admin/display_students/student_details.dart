import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/user_details_tile.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDetails extends StatefulWidget {

  final UserModel currentUser;

  StudentDetails({this.currentUser});

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {

  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
      child: StreamBuilder(
        stream: databaseService.getStudents(userId : widget.currentUser.uid),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Loading(loadingText: "Fetching latest data",);
          } else if(snapshot.data.documents.length == 0) {
            return InfoDisplay(textToDisplay: "You don't have any students as of now",);
          } else {
            return Column(
              children: [
                Text("Your Students", style: TextStyle(fontSize: 20, color: Colors.black87),),
                SizedBox(height: 5,),
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0,),
                          child: UserDetailsTile(
                            displayName: snapshot.data.documents[index].data()["displayName"],
                            email: snapshot.data.documents[index].data()["email"],
                            photoUrl: snapshot.data.documents[index].data()["photoUrl"],
                            isHighlightTile: false,
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
    );
  }
}
