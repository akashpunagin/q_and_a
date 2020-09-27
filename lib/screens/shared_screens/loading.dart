import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  final loadingText;
  final Color textColor;
  final Color spinKitColor;
  Loading({this.loadingText, this.textColor, this.spinKitColor});

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitFadingCircle(
          color: spinKitColor == null ? Colors.blue : spinKitColor,
          size: 50.0,
        ),
        SizedBox(height: 20.0,),
        loadingText != null ? Text("$loadingText . . .",
          style: TextStyle(
            fontSize: 20.0,
            color: textColor == null ? Colors.black54 : textColor
          ),
        ) : Container(),
      ],
    );
  }
}

