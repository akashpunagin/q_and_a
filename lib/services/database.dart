import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:q_and_a/models/user_model.dart';

class DatabaseService {

  //Constant titles
  static String userCollectionTitle = "users"; // all users (teacher and student)
  static String quizCollectionTitle = "quizzes"; // quizzes of teachers
  static String questionsCollectionTitle = "questions"; // questions of quizzes of teachers
  static String studentProgressCollectionTitle = "student_progress"; // progress of students
  static String teachersCollectionTitle = "teachers"; // teachers of students
  static String studentsCollectionTitle = "students"; // students of teachers
  static String quizResultSubmissionTitle = "quiz_submissions"; // quiz submissions of student

  //Collection Reference
  final CollectionReference userDetailsCollection = FirebaseFirestore.instance.collection(userCollectionTitle);

  // Adding to database

  Future<void> addUserWithDetails({Map userData}) async {
    await userDetailsCollection.doc(userData['uid']).set(userData).catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuizDetails({Map quizData, String quizId, String userId}) async {
    await userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .set(quizData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuestionDetails({Map questionData, String quizId, String questionId, String userId}) async {
    await userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .doc(questionId)
        .set(questionData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addStudentProgress({String userId, Map progressData}) async {
    QuerySnapshot querySnapshot = await userDetailsCollection
        .where("email", isEqualTo: progressData['teacher'])
        .limit(1)
        .get();

    progressData['teacher'] = querySnapshot.docs[0].data()["displayName"];

    await userDetailsCollection
        .doc(userId)
        .collection(studentProgressCollectionTitle)
        .doc()
        .set(progressData)
        .catchError((e){
      print(e.toString());
    });
  }





  Future<void> addQuizSubmissionDetails({String teacherId, Map quizResultData}) async {
    await userDetailsCollection
        .doc(teacherId)
        .collection(quizResultSubmissionTitle)
        .doc()
        .set(quizResultData)
        .catchError((e){
      print(e.toString());
    });
  }






  Future<void> addTeacher({String userId, Map teacherData}) async {
    await userDetailsCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .add(teacherData);
  }

  // Get data from database

  Stream<QuerySnapshot> getStudents({String userId})  {
    return userDetailsCollection
        .doc(userId)
        .collection(studentsCollectionTitle)
        .snapshots();
  }


  Stream<QuerySnapshot> getQuizDetails({String userId})  {
    return userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .snapshots();
  }

  Stream<QuerySnapshot> getQuizQuestionDetails({String quizId, String userId}) {
    return userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .snapshots();
  }

  Future<QuerySnapshot> getQuizQuestionDocuments({String quizId, String userId}) {
    return userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .get();
  }

  Future<QuerySnapshot> getStudentProgress({String userId}) {
    return userDetailsCollection
        .doc(userId)
        .collection(studentProgressCollectionTitle)
        .orderBy('createAt', descending: true)
        .get();
  }

  Stream<QuerySnapshot> getQuizSubmissionDetails({String teacherId}) {
    return userDetailsCollection
        .doc(teacherId)
        .collection(quizResultSubmissionTitle)
        .orderBy('createAt', descending: true)
        .snapshots();
  }


  // Get user from database
  DocumentReference getUserWithUserId(String userId) {
    return userDetailsCollection.doc(userId);
  }

  Stream<QuerySnapshot> getUserWithField({String fieldKey, String fieldValue, int limit}) {
    return limit == null ? userDetailsCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .snapshots() :
    userDetailsCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .limit(1)
        .snapshots();
  }

  Future<QuerySnapshot> getUserDocumentWithField({String fieldKey, String fieldValue, int limit}) {
    return userDetailsCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> getTeachersOfUser({String userId})  {
    return userDetailsCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .snapshots();
  }

  // Update data in database

  Future<void> updateTeacherEmail({String newTeacherEmail, String currentTeacherEmail, StudentModel studentModel}) {

    print("NEW $newTeacherEmail CURRENT $currentTeacherEmail");

    getUserDocumentWithField(fieldKey: "email", fieldValue: newTeacherEmail, limit: 1).then((value) {

      Map<String, String> userMap = {
        'displayName' : studentModel.displayName,
        'email' : studentModel.email,
        'photoUrl' : studentModel.photoUrl,
      };

      userDetailsCollection
        .doc(value.docs[0].id)
        .collection(studentsCollectionTitle)
        .add(userMap);
    });

    getUserDocumentWithField(fieldKey: "email", fieldValue: currentTeacherEmail, limit: 1).then((value) async{

      QuerySnapshot result = await userDetailsCollection
        .doc(value.docs[0].id)
        .collection(studentsCollectionTitle)
        .where('email', isEqualTo: studentModel.email)
        .limit(1)
        .get();

      if(result.docs.length > 0) {
        userDetailsCollection
          .doc(value.docs[0].id)
          .collection(studentsCollectionTitle)
          .doc(result.docs[0].id)
          .delete();
      }

    });

    return userDetailsCollection.doc(studentModel.uid)
        .update({"teacherEmail": newTeacherEmail})
        .catchError((e) {
      print(e.toString());
    });
  }

  updateStudentTotals({String userId, int nCorrect, int nWrong, int nNotAttempted}) {
    checkFieldAndUpdate({DocumentSnapshot result, int field, String totalField}) {
      if(result.data().containsKey(totalField) == true) {
        userDetailsCollection.doc(userId)
            .update({totalField : result.data()[totalField] + field});
      } else {
        userDetailsCollection.doc(userId)
            .update({totalField : field});
      }
    }

    DocumentReference result = getUserWithUserId(userId);
    result.get().then((result){
      checkFieldAndUpdate(result: result, field: nCorrect, totalField: "nTotalCorrect");
      checkFieldAndUpdate(result: result, field: nWrong, totalField: "nTotalWrong");
      checkFieldAndUpdate(result: result, field: nCorrect, totalField: "nTotalNotAttempted");
      checkFieldAndUpdate(result: result, field: 1, totalField: "nTotalQuizSubmitted");
    });
  }


  Future<bool> isUserExists({String userId}) async {
    try {
      var doc = await userDetailsCollection.doc(userId).get();

      if ( doc.exists ) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> updateDeviceToken({String userId, String deviceToken}) {
    return userDetailsCollection.doc(userId)
        .update({"deviceToken": deviceToken})
        .catchError((e) {
      print(e.toString());
    });
  }




  // Delete from database
  deleteQuizDetails({String userId, String quizId}) {

    userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .get().then((snapshot) {
          for(DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
    });

    userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .delete();
  }

  Future deleteQuestionDetails({String userId, String quizId, String questionId}) {
    return userDetailsCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .doc(questionId)
        .delete();
  }

  Future<void> removeTeacher({String userId, String teacherEmail}) async {
    QuerySnapshot result = await userDetailsCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .where("email", isEqualTo: teacherEmail)
        .limit(1)
        .get();

    return userDetailsCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .doc(result.docs[0].reference.id)
        .delete();

  }

  deleteQuizSubmissions({String userId}) {
    return userDetailsCollection
        .doc(userId)
        .collection(quizResultSubmissionTitle)
        .get().then((snapshot) {
      for(DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

}