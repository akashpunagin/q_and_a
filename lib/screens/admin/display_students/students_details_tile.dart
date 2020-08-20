import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentDetailsTile extends StatelessWidget {

  final String displayName;
  final String email;
  final String photoUrl;
  StudentDetailsTile({this.displayName, this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5, 0.7],
          colors: [
            Colors.blue[300],
            Colors.blue[500],
            Colors.blue[600],
          ]
        ),
        borderRadius: BorderRadius.circular(10.0)
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FaIcon(FontAwesomeIcons.userGraduate, size: 18.0,),
                  SizedBox(width: 5.0,),
                  Text(displayName, style: TextStyle(fontSize: 18.0),),
                ],
              ),
              SizedBox(height: 10.0,),
              Row(
                children: <Widget>[
                  Icon(Icons.email, size: 18.0,),
                  SizedBox(width: 5.0,),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: email.split("@")[0],
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                        TextSpan(
                          text: "@${email.split("@")[1]}",
                          style: TextStyle(fontSize: 12.0, color: Colors.black),
                        ),
                      ]
                    ),
                  )
                ],
              ),
            ],
          ),
          Image.network(
            photoUrl,
            height: 65.0,
            width: 65.0,
          )
        ],
      ),
    );
  }
}
