import 'package:q_and_a/screens/not_admin/home/home_not_admin.dart';
import 'package:q_and_a/screens/not_admin/not_admin_profile/my_profile_not_admin.dart';
import 'package:q_and_a/screens/not_admin/teacher_profile/teacher_profile.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotAdmin extends StatefulWidget {
  @override
  _NotAdminState createState() => _NotAdminState();
}

class _NotAdminState extends State<NotAdmin> {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  int navBarIndex = 0 ;

  @override
  Widget build(BuildContext context) {

    List<Widget>_screens = [
      HomeNotAdmin(),
      TeacherProfile(),
      MyProfileNotAdmin(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        title: appBar(context),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                displayLogOutAlert(context);
              },
              icon: FaIcon(FontAwesomeIcons.signOutAlt, size: 20.0,),
              label: Text("Logout")
          ),
        ],
      ),
      body: _screens[navBarIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.transparent,
        height: 55,
        animationDuration: Duration(milliseconds: 200),
        onTap: (index) {
          setState(() {
            navBarIndex = index;
          });
        },
        items: [
          FaIcon(FontAwesomeIcons.university, size: 22.0,),
          FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20.0,),
          FaIcon(FontAwesomeIcons.userGraduate, size: 20.0,),
        ],
      ),
    );
  }
}
