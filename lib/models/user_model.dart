class UserModel {

  String uid;
  bool isAdmin;
  String displayName;
  String photoUrl;
  String email;

  UserModel({this.uid, this.isAdmin, this.displayName, this.photoUrl, this.email});
}

class StudentModel extends UserModel {
  String nTotalCorrect;
  String nTotalWrong;
  String nTotalNotAttempted;
  String nTotalQuizSubmitted;
  String teacherEmail;

  StudentModel({this.nTotalCorrect, this.nTotalWrong, this.nTotalQuizSubmitted, this.nTotalNotAttempted, this.teacherEmail});
}