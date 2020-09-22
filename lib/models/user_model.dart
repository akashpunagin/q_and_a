class UserModel {

  final String uid;
  bool isAdmin;
  final String displayName;
  final String photoUrl;
  final String email;

  UserModel({this.uid, this.isAdmin, this.displayName, this.photoUrl, this.email});
}