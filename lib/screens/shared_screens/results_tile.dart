import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResultsTile extends StatelessWidget {

  final String teacherName;
  final String topic;
  final String nCorrect;
  final String nWrong;
  final String nNotAttempted;
  final String nTotal;
  final String index;
  final String date;
  ResultsTile({this.teacherName, this.topic, this.nCorrect, this.nWrong, this.nNotAttempted, this.nTotal, this.index, this.date});

  Widget _getColumnForLabel(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center,),
        Text(value, style: TextStyle(color:color, fontSize: 18.0, fontWeight: FontWeight.w900),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13,vertical: 5),
      margin: EdgeInsets.symmetric(vertical: 5.0),
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
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(teacherName, style: TextStyle(fontSize: 15.0),),
              Text(date.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200),),
              Text(index, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w200),),
            ],
          ),
          Text("$topic"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _getColumnForLabel("Total", nTotal, Colors.black),
              _getColumnForLabel("Correct", nCorrect, Colors.green[800]),
              _getColumnForLabel("Wrong", nWrong, Colors.redAccent),
              _getColumnForLabel("Not\nAttempted", nNotAttempted, Colors.black),
            ],
          )
        ],
      ),
    );
  }
}
