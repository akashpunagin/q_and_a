import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploader {
  File file;
  String userId;
  String field;
  String quizId;
  String questionId;
  bool isFromCreateQuiz;
  ImageUploader({this.file, this.userId, this.field, this.quizId, this.questionId, this.isFromCreateQuiz});


  final FirebaseStorage _storage = FirebaseStorage(storageBucket: "gs://qanda-882f7.appspot.com");

  StorageUploadTask _uploadTask;

  Future<String> startUpload() async {
    String filePath;
    if(isFromCreateQuiz == true) {
      filePath = "images/$field/$userId/$quizId";
    } else {
      filePath = "images/$field/$quizId/$questionId/$userId";
    }
    _uploadTask = _storage.ref().child(filePath).putFile(file);
    StorageTaskSnapshot storageTaskSnapshot = await _uploadTask.onComplete;
    String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  deleteUploaded() async {
    String filePath;
    if(isFromCreateQuiz == true) {
      filePath = "images/$field/$userId/$quizId";
    } else {
      filePath = "images/$field/$quizId/$questionId/$userId";
    }
    try {
      await _storage.ref().child(filePath).delete();
    } catch (e) {
      print(e.toString());
    }

  }

}