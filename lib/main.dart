import 'package:firebase_core/firebase_core.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      child: MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(
            bodyText2: GoogleFonts.montserrat()
          )
        ),
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}