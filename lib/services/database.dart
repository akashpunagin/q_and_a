import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  //Constant titles
  static String userCollectionTitle = "users";
  static String quizCollectionTitle = "quizzes";
  static String questionsCollectionTitle = "questions";
  static String studentProgressCollection = "student_progress";
  static String teachersCollectionTitle = "teachers";

  //Collection Reference
  final CollectionReference userDetailsCollection = Firestore.instance.collection(userCollectionTitle);


  // Adding to database

  Future<void> addUserWithDetails({Map userData}) async {
    await userDetailsCollection.document(userData['uid']).setData(userData).catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuizDetails({Map quizData, String quizId, String userId}) async {
    await userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .setData(quizData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuestionDetails({Map questionData, String quizId, String questionId, String userId}) async {
    await userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .collection(questionsCollectionTitle)
        .document(questionId)
        .setData(questionData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addStudentProgress({String userId, Map progressData}) async {
    QuerySnapshot querySnapshot = await userDetailsCollection
        .where("email", isEqualTo: progressData['teacher'])
        .limit(1)
        .getDocuments();

    progressData['teacher'] = querySnapshot.documents[0].data['displayName'];

    await userDetailsCollection
        .document(userId)
        .collection(studentProgressCollection)
        .document()
        .setData(progressData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addTeacher({String userId, Map teacherData}) async {
    await userDetailsCollection
        .document(userId)
        .collection(teachersCollectionTitle)
        .document()
        .setData(teacherData);
  }

  // Get data from database

  Stream<QuerySnapshot> getQuizDetails({String userId})  {
    return userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .snapshots();
  }

  Stream<QuerySnapshot> getQuizQuestionDetails({String quizId, String userId}) {
    return userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .collection(questionsCollectionTitle)
        .snapshots();
  }

  Future<QuerySnapshot> getStudentProgress({String userId}) {
    return userDetailsCollection
        .document(userId)
        .collection(studentProgressCollection)
        .orderBy('createAt', descending: true)
        .getDocuments();
  }

  // Get user from database
  DocumentReference getUserWithUserId(String userId) {
    return userDetailsCollection.document(userId);
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
        .getDocuments();
  }

  Stream<QuerySnapshot> getTeachersOfUser({String userId})  {
    return userDetailsCollection
        .document(userId)
        .collection(teachersCollectionTitle)
        .snapshots();
  }

  // Update data in database

  Future<void> updateTeacherEmail({String userId, String teacherEmail}) {
    return userDetailsCollection.document(userId)
        .setData({"teacherEmail": teacherEmail}, merge: true)
        .catchError((e) {
      print(e.toString());
    });
  }

  updateStudentTotals({String userId, int nCorrect, int nWrong, int nNotAttempted}) {
    checkFieldAndUpdate({DocumentSnapshot result, int field, String totalField}) {
      if(result.data.containsKey(totalField) == true) {
        userDetailsCollection.document(userId)
            .setData({totalField : result.data[totalField] + field}, merge: true);
      } else {
        userDetailsCollection.document(userId)
            .setData({totalField : field}, merge: true);
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
      var doc = await userDetailsCollection.document(userId).get();

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

  // Delete from database
  deleteQuizDetails({String userId, String quizId}) {

    userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .collection(questionsCollectionTitle)
        .getDocuments().then((snapshot) {
          for(DocumentSnapshot doc in snapshot.documents) {
            doc.reference.delete();
          }
    });

    userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .delete();
  }

  Future deleteQuestionDetails({String userId, String quizId, String questionId}) {
    return userDetailsCollection
        .document(userId)
        .collection(quizCollectionTitle)
        .document(quizId)
        .collection(questionsCollectionTitle)
        .document(questionId)
        .delete();
  }

  Future<void> removeTeacher({String userId, String teacherEmail}) async {
    QuerySnapshot result = await userDetailsCollection
        .document(userId)
        .collection(teachersCollectionTitle)
        .where("email", isEqualTo: teacherEmail)
        .limit(1)
        .getDocuments();

    return userDetailsCollection
        .document(userId)
        .collection(teachersCollectionTitle)
        .document(result.documents[0].reference.documentID)
        .delete();

  }

}