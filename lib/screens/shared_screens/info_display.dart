import 'package:flutter/material.dart';

class InfoDisplay extends StatelessWidget {

  final String textToDisplay;
  InfoDisplay({this.textToDisplay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/warning.png",
            scale: 1.7,
          ),
          SizedBox(height: 20.0,),
          Text(
            textToDisplay,
            style: TextStyle(
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
