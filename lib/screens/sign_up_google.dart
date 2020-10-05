import 'package:google_fonts/google_fonts.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SignUpGoogle extends StatefulWidget {

  final Function setWrapperState;
  SignUpGoogle({this.setWrapperState});

  @override
  _SignUpGoogleState createState() => _SignUpGoogleState();
}

class _SignUpGoogleState extends State<SignUpGoogle> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  bool _isLoading = false;

  Map<String, dynamic> userMap = {};

  showErrorSigningInAlert() {
    Alert(
      context: context,
      type: AlertType.warning,
      style: alertStyle,
      title: "Couldn't Sign in",
      desc: "It seems there was a problem signing you in. Would you like to try again?",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context);
          } ,
          gradient: LinearGradient(colors: [
            Colors.black54,
            Colors.black38,
          ]),
        ),
        DialogButton(
          child: Text(
            "Try again",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            _signUp();
          } ,
          gradient: LinearGradient(colors: [
            Colors.blue[400],
            Colors.blue[500],
          ]),
        )
      ],
    ).show();

  }

  _signUp() async {
    setState(() {
      _isLoading = true;
    });

    await authService.signInWithGoogle().then( (user) async {
      if(user == null) {
        showErrorSigningInAlert();
      } else {
        databaseService.isUserExists(userId: user.uid).then((isUserExists) async {
          if(!isUserExists) {
            userMap = {
              "displayName" : user.displayName,
              "photoUrl" : user.photoUrl,
              "email" : user.email,
              "uid" : user.uid,
            };
            await databaseService.addUserWithDetails(userData: userMap);
            widget.setWrapperState();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          brightness: Brightness.light,
          title: appBar(context),
          elevation: 0.0,
        ),
        body: Loading(loadingText: "Just a moment",),
      ) : Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 25),
                  children: <TextSpan>[
                    TextSpan(text: 'Q', style: GoogleFonts.comfortaa(
                        textStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 60.0)
                    )),
                    TextSpan(text: 'and', style: GoogleFonts.comfortaa(
                        textStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.black54, fontSize: 58.0, letterSpacing: -6)
                    )),
                    TextSpan(text: 'A', style: GoogleFonts.comfortaa(
                        textStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 60.0)
                    )),
                  ],
                )
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width - 40,
                child: Carousel(
                  images: [
                    ExactAssetImage("assets/images/login_screen/login_screen_1.png"),
                    ExactAssetImage("assets/images/login_screen/login_screen_2.png"),
                    ExactAssetImage("assets/images/login_screen/login_screen_3.png"),
                  ],
                  dotSize: 5.0,
                  dotSpacing: 20.0,
                  dotColor: Colors.black38,
                  dotIncreasedColor: Colors.blueAccent,
                  indicatorBgPadding: 55.0,
                  dotBgColor: Colors.transparent,
                  borderRadius: true,
                  moveIndicatorFromBottom: 180.0,
                  noRadiusForIndicator: true,
                  animationDuration: Duration(seconds: 1),
                  autoplayDuration: Duration(seconds: 3),
                  boxFit: BoxFit.contain,
                )
            ),
            blueButton(context: context, label: "Google Sign Up/Sign In", onPressed: _signUp),
          ],
        ),
      ),
    );
  }
}
