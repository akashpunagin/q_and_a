import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// Sign Up page info text TextStyle
const infoSignUpTextStyle = TextStyle(
  color: Colors.black87,
  fontSize: 20.0,
);

// Alert style for ALERT dialog box
var alertStyle = AlertStyle(
  animationType: AnimationType.fromTop,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  descStyle: TextStyle(fontWeight: FontWeight.bold),
  animationDuration: Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(0.0),
    side: BorderSide(
      color: Colors.grey,
    ),
  ),
  titleStyle: TextStyle(
    color: Colors.red,
  ),
);

// Default quiz image URL in home screen
var defaultQuizImageURL = "https://images.unsplash.com/photo-1557318041-1ce374d55ebf?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80";

// Content padding for Text fields inside Stack widget
var textFieldStackContentPaddingWithTimes = EdgeInsets.fromLTRB(0, 6, 130, 6);
var textFieldStackContentPaddingWithoutTimes = EdgeInsets.fromLTRB(0, 6, 90, 6);