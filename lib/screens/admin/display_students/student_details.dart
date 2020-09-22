import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/info_display.dart';
import 'package:q_and_a/screens/shared_screens/user_details_tile.dart';
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


    final user = Provider.of<UserModel>(context);

    DocumentReference result = databaseService.getUserWithUserId(user.uid);
    Future<String> email = result.get().then((result){
      if ( result.data().containsKey("email") ) {
        return result.data()['email'];
      } else {
        return null;
      }

    });

    return FutureBuilder(
      future: email,
      builder: (context, future){

        if(future.data == null) {
          return Loading(loadingText: "Fetching your email",);
        } else {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20.0),
            child: FutureBuilder(
              future: databaseService.getStudents(teacherEmail: future.data),
              builder: (context, future) {
                if(future.data == null) {
                  return Loading(loadingText: "Fetching latest data",);
                } else if(future.data.length == 0) {
                  return InfoDisplay(textToDisplay: "You don't have any students as of now",);
                } else {
                  return Column(
                    children: [
                      Text("Your Students", style: TextStyle(fontSize: 20, color: Colors.black87),),
                      SizedBox(height: 20,),
                      SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: future.data.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0,),
                                child: UserDetailsTile(
                                  displayName: future.data[index]["displayName"],
                                  email: future.data[index]["email"],
                                  photoUrl: future.data[index]["photoUrl"],
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
      },
    );
  }
}
