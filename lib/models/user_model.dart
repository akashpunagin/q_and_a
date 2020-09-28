class UserModel {

  String uid;
  bool isAdmin;
  String displayName;
  String photoUrl;
  String email;

  UserModel({this.uid, this.isAdmin, this.displayName, this.photoUrl, this.email});

  Map<String, dynamic> toMapNotNullValues() {
    return {
      'uid': uid,
      'isAdmin': isAdmin,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
    };
  }

}

class StudentModel extends UserModel {
  int nTotalCorrect;
  int nTotalWrong;
  int nTotalNotAttempted;
  int nTotalQuizSubmitted;
  String teacherEmail;

  StudentModel({this.nTotalCorrect, this.nTotalWrong, this.nTotalQuizSubmitted, this.nTotalNotAttempted, this.teacherEmail});

  Map<String, dynamic> toMapNotNullValues() {
    return {
      'uid': uid,
      'isAdmin': isAdmin,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'nTotalCorrect': nTotalCorrect,
      'nTotalWrong': nTotalWrong,
      'nTotalQuizSubmitted': nTotalQuizSubmitted,
      'nTotalNotAttempted': nTotalNotAttempted,
    };
  }
}