import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/display_students/student_details.dart';
import 'package:q_and_a/screens/admin/admin_profile/my_profile_admin.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/auth.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home/home_admin.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {

  int navBarIndex = 0 ;

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  UserModel currentUser;
  TeacherModel teacherModel = TeacherModel();
  bool isShowHomeAdminAlerts = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        currentUser = Provider.of<UserModel>(context, listen: false);

        teacherModel.uid = currentUser.uid;
        teacherModel.isAdmin = true;
        teacherModel.displayName = currentUser.displayName;
        teacherModel.photoUrl = currentUser.photoUrl;
        teacherModel.email = currentUser.email;
        teacherModel.isShowHomeAdminAlerts = true;

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> _screens = [
      HomeAdmin(currentUser: teacherModel,),
      StudentDetails(currentUser: currentUser,),
      MyProfileAdmin(currentUser: currentUser,),
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
              icon: FaIcon(FontAwesomeIcons.signOutAlt, size: 20.0, color: Colors.black54,),
              label: Text("Logout", style: TextStyle(color: Colors.black54),)
          ),
        ],
      ),
      body: teacherModel == null || teacherModel.toMapNotNullValues().containsValue(null) ? Loading(
        loadingText: "Loading your credentials",
      ) : _screens[navBarIndex],
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
          FaIcon(FontAwesomeIcons.users, size: 22.0,),
          FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20.0,),
        ],
      ),
    );
  }
}
