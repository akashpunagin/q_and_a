import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  final loadingText;
  Loading({this.loadingText});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Colors.blue,
            size: 50.0,
          ),
          SizedBox(height: 20.0,),
          loadingText != null ? Text("$loadingText . . .",
            style: TextStyle(fontSize: 20.0, color: Colors.black54),) : Container(),
        ],
      ),
    );
  }
}

