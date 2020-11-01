import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  static String tokensCollectionTitle = "tokens";  // tokens of student or teacher

  //Collection Reference
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection(userCollectionTitle);

  // Adding to database

  Future<void> addUserWithDetails({Map userData}) async {
    await usersCollection.doc(userData['uid']).set(userData).catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuizDetails({Map quizData, String quizId, String userId}) async {
    await usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .set(quizData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> addQuestionDetails({Map questionData, String quizId, String questionId, String userId}) async {
    await usersCollection
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
    QuerySnapshot querySnapshot = await usersCollection
        .where("email", isEqualTo: progressData['teacher'])
        .limit(1)
        .get();

    progressData['teacher'] = querySnapshot.docs[0].data()["displayName"];

    await usersCollection
        .doc(userId)
        .collection(studentProgressCollectionTitle)
        .doc()
        .set(progressData)
        .catchError((e){
      print(e.toString());
    });
  }





  Future<void> addQuizSubmissionDetails({String teacherId, Map quizResultData}) async {
    await usersCollection
        .doc(teacherId)
        .collection(quizResultSubmissionTitle)
        .doc()
        .set(quizResultData)
        .catchError((e){
      print(e.toString());
    });
  }






  Future<void> addTeacher({String userId, Map teacherData}) async {
    await usersCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .add(teacherData);
  }

  // Get data from database

  Stream<QuerySnapshot> getStudents({String userId})  {
    return usersCollection
        .doc(userId)
        .collection(studentsCollectionTitle)
        .snapshots();
  }


  Stream<QuerySnapshot> getQuizDetails({String userId})  {
    return usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .snapshots();
  }

  Stream<QuerySnapshot> getQuizQuestionDetails({String quizId, String userId}) {
    return usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .snapshots();
  }

  Future<QuerySnapshot> getQuizQuestionDocuments({String quizId, String userId}) {
    return usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .get();
  }

  Future<QuerySnapshot> getStudentProgress({String userId}) {
    return usersCollection
        .doc(userId)
        .collection(studentProgressCollectionTitle)
        .orderBy('createAt', descending: true)
        .get();
  }

  Stream<QuerySnapshot> getQuizSubmissionDetails({String teacherId}) {
    return usersCollection
        .doc(teacherId)
        .collection(quizResultSubmissionTitle)
        .orderBy('createAt', descending: true)
        .snapshots();
  }


  // Get user from database

  DocumentReference getUserWithUserId(String userId) {
    return usersCollection.doc(userId);
  }

  Stream<QuerySnapshot> getUserWithField({String fieldKey, String fieldValue, int limit}) {
    return limit == null ? usersCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .snapshots() :
    usersCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .limit(1)
        .snapshots();
  }

  Future<QuerySnapshot> getUserDocumentWithField({String fieldKey, String fieldValue, int limit}) {
    return usersCollection
        .where(fieldKey, isEqualTo: fieldValue)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> getTeachersOfUser({String userId})  {
    return usersCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .snapshots();
  }

  // Update data in database

  Future<void> updateQuizDetails({Map quizData, String quizId, String userId}) async {
    await usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .update(quizData)
        .catchError((e){
      print(e.toString());
    });
  }

  Future<void> updateTeacherEmail({String newTeacherEmail, String currentTeacherEmail, StudentModel studentModel}) {
    if(newTeacherEmail != null) {
      // add student in students collection
      getUserDocumentWithField(fieldKey: "email", fieldValue: newTeacherEmail, limit: 1).then((value) {
        Map<String, String> userMap = {
          'displayName' : studentModel.displayName,
          'email' : studentModel.email,
          'photoUrl' : studentModel.photoUrl,
        };
        usersCollection
          .doc(value.docs[0].id)
          .collection(studentsCollectionTitle)
          .add(userMap);
      });
    }

    if(currentTeacherEmail != null) {
      // delete student from current teacher
      getUserDocumentWithField(fieldKey: "email", fieldValue: currentTeacherEmail, limit: 1).then((value) async {
        QuerySnapshot result = await usersCollection
          .doc(value.docs[0].id)
          .collection(studentsCollectionTitle)
          .where('email', isEqualTo: studentModel.email)
          .limit(1)
          .get();
        if(result.docs.length > 0) {
          usersCollection
            .doc(value.docs[0].id)
            .collection(studentsCollectionTitle)
            .doc(result.docs[0].id)
            .delete();
        }
      });
    }

    // update teacherEmail field of student
    return usersCollection.doc(studentModel.uid)
        .update({"teacherEmail": newTeacherEmail})
        .catchError((e) {
      print(e.toString());
    });
  }

  updateStudentTotals({String userId, int nCorrect, int nWrong, int nNotAttempted}) {
    checkFieldAndUpdate({DocumentSnapshot result, int field, String totalField}) {
      if(result.data().containsKey(totalField) == true) {
        usersCollection.doc(userId)
            .update({totalField : result.data()[totalField] + field});
      } else {
        usersCollection.doc(userId)
            .update({totalField : field});
      }
    }

    DocumentReference result = getUserWithUserId(userId);
    result.get().then((result){
      checkFieldAndUpdate(result: result, field: nCorrect, totalField: "nTotalCorrect");
      checkFieldAndUpdate(result: result, field: nWrong, totalField: "nTotalWrong");
      checkFieldAndUpdate(result: result, field: nNotAttempted, totalField: "nTotalNotAttempted");
      checkFieldAndUpdate(result: result, field: 1, totalField: "nTotalQuizSubmitted");
    });
  }


  Future<bool> isUserExists({String userId}) async {
    try {
      var doc = await usersCollection.doc(userId).get();

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

  Future<void> updateUserDeviceToken({String userId, String deviceToken}) async {
    await usersCollection.doc(userId)
      .collection(tokensCollectionTitle)
      .doc(deviceToken)
      .set({
        'token': deviceToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
  }




  // Delete from database
  deleteQuizDetails({String userId, String quizId}) {

    usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .get().then((snapshot) {
          for(DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
    });

    usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .delete();
  }

  Future deleteQuestionDetails({String userId, String quizId, String questionId}) {
    return usersCollection
        .doc(userId)
        .collection(quizCollectionTitle)
        .doc(quizId)
        .collection(questionsCollectionTitle)
        .doc(questionId)
        .delete();
  }

  Future<void> removeTeacher({String userId, String teacherEmail}) async {
    QuerySnapshot result = await usersCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .where("email", isEqualTo: teacherEmail)
        .limit(1)
        .get();

    return usersCollection
        .doc(userId)
        .collection(teachersCollectionTitle)
        .doc(result.docs[0].reference.id)
        .delete();

  }

  Future<void> removeUserToken({@required String userId, @required String token}) {
    return usersCollection
        .doc(userId)
        .collection(tokensCollectionTitle)
        .doc(token)
        .delete();
  }

  // deleteQuizSubmissions({String userId}) {
  //   return userDetailsCollection
  //       .doc(userId)
  //       .collection(quizResultSubmissionTitle)
  //       .get().then((snapshot) {
  //     for(DocumentSnapshot doc in snapshot.docs) {
  //       doc.reference.delete();
  //     }
  //   });
  // }

}