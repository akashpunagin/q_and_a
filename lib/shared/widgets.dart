import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Widget appBar(BuildContext context) {
  return RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 25),
      children: <TextSpan>[
        TextSpan(text: 'Q', style: GoogleFonts.comfortaa(
            textStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 28.0)
        )),
        TextSpan(text: 'and', style: GoogleFonts.comfortaa(
          textStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.black54, fontSize: 28.0, letterSpacing: -2)
        )),
        TextSpan(text: 'A', style: GoogleFonts.comfortaa(
          textStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 28.0)
        )),
      ],
    )
  );
}

Widget blueButton({BuildContext context, String label, Function onPressed, double width}) {
  return ButtonTheme(
    minWidth: width == null ? MediaQuery.of(context).size.width : width,
    height: 50.0,
    child: FlatButton(
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      onPressed: onPressed,
      child: Text(
          label,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(fontSize: 17.0, color: Colors.white),
        ),
      ),
    ),
  );
}

final AuthService authService = AuthService();
displayLogOutAlert(BuildContext context) {
  Alert(
    context: context,
    style: alertStyle,
    type: AlertType.warning,
    title: "Logout alert",
    desc: "Are you sure you want to logout?",
    buttons: [
      DialogButton(
        child: Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () async {
          Navigator.pop(context);
          await authService.signOut();
        },
        gradient: LinearGradient(colors: [
          Colors.black54,
          Colors.black38,
        ]),
      ),
      DialogButton(
        child: Text(
          "Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        gradient: LinearGradient(colors: [
          Colors.blue[400],
          Colors.blue[500],
        ]),
      )
    ],
  ).show();
}

displaySelectGmailAlert({BuildContext context, Function onPressed}) {
  Alert(
    context: context,
    style: alertStyle,
    type: AlertType.info,
    title: "Select Gmail",
    desc: "In the next screen, select share with Gmail",
    buttons: [
      DialogButton(
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
          onPressed();
        },
        width: 120,
      )
    ],
  ).show();
}


Widget textFieldStackButtonCamera(Function onPressed) {
  return Container(
    margin: EdgeInsets.fromLTRB(6, 6, 0, 25),
    child: IconButton(
      icon: FaIcon(FontAwesomeIcons.camera, size: 22.0, color: Colors.blueAccent.withOpacity(0.9),),
      onPressed: onPressed,
    ),
  );
}

Widget textFieldStackButtonImages(Function onPressed) {
  return Container(
    margin: EdgeInsets.fromLTRB(6, 6, 44, 25),
    child: IconButton(
      icon: FaIcon(FontAwesomeIcons.images, size: 22.0, color: Colors.blueAccent.withOpacity(0.9),),
      onPressed: onPressed,
    ),
  );
}

Widget textFieldStackButtonTimes(Function onPressed) {
  return Container(
    margin: EdgeInsets.fromLTRB(6, 6, 84, 25),
    child: IconButton(
      icon: FaIcon(FontAwesomeIcons.times, size: 22.0, color: Colors.black54,),
      onPressed: onPressed,
    ),
  );
}