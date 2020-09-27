import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  //Constant titles
  static String userCollectionTitle = "users";

  // static String usersTeacherCollectionTitle = "users_teacher";
  // static String usersStudentCollectionTitle = "users_students";

  static String quizCollectionTitle = "quizzes";
  static String questionsCollectionTitle = "questions";
  static String studentProgressCollectionTitle = "student_progress";
  static String teachersCollectionTitle = "teachers";
  static String quizResultSubmissionTitle = "quiz_submissions";

  //Collection Reference
  final CollectionReference userDetailsCollection = FirebaseFirestore.instance.collection(userCollectionTitle);

  // final CollectionReference usersTeacherCollection = FirebaseFirestore.instance.collection(usersTeacherCollectionTitle);
  // final CollectionReference usersStudentsCollection = FirebaseFirestore.instance.collection(usersStudentCollectionTitle);


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
        .doc()
        .set(teacherData);
  }

  // Get data from database

  Future<List<Map<String,String>>> getStudents({String teacherEmail}) async {

    // Map<String,String> student = {};
    List<Map<String,String>> students = [];

    var result =  await userDetailsCollection.get();
    // print(result.documents);

    for (DocumentSnapshot document in result.docs) {

      if(document.data()["isAdmin"] == false) {

        // print("STUDENT: ${document.data['displayName']}");

        var teachers = await userDetailsCollection
          .doc(document.data()["uid"])
          .collection(teachersCollectionTitle)
          .where('email', isEqualTo: teacherEmail)
          .get();


        if(teachers.docs.length > 0) {
          // print("STUDENT: ${document.data['email']} is teacher of $teacherEmail");

          Map<String,String> student = {
            'displayName' : document.data()['displayName'],
            'email' : document.data()['email'],
            'photoUrl' : document.data()['photoUrl'],
          };
          students.add(student);


          // return getUserWithUserId(document.data['uid']).snapshots();
        }

      }
    }

    // print(students);
    return students;

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

  Future<void> updateTeacherEmail({String userId, String teacherEmail}) {
    return userDetailsCollection.doc(userId)
        .update({"teacherEmail": teacherEmail})
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
            .set({totalField : field});
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

}