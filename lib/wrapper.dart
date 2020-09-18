import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/admin.dart';
import 'package:q_and_a/screens/not_admin/not_admin.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/screens/sign_up_google.dart';
import 'package:q_and_a/screens/user_role_wrapper.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final DatabaseService databaseService = DatabaseService();

  setWrapperState() {
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);

    if (user == null){
      return SignUpGoogle(setWrapperState: setWrapperState,);
    } else {
      DocumentReference result = databaseService.getUserWithUserId(user.uid);
      Future<StatefulWidget> widget = result.get().then((result){
        if (result.data().containsKey("isAdmin")) {
          return result.data()['isAdmin'] ? Admin() : NotAdmin();
        } else {
          return UserRoleWrapper(userSnapshot: result);
        }
      });


      return FutureBuilder(
        future: widget,
        builder: (context, future) {
          if(future.connectionState == ConnectionState.waiting || !future.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                brightness: Brightness.light,
                title: appBar(context),
                elevation: 0.0,
              ),
              body:Loading(
                loadingText: future.data == SignUpGoogle() ? "Signing you in" : "Logging you in",
              ),
            );
          } else {
            return future.data;
          }
        },
      );
    }
  }
}