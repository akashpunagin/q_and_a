import 'package:q_and_a/services/image_uploader.dart';

deleteStorageImagesOfQuiz({
  String teacherId,
  String quizId,
  String questionId,
  String questionImageUrl,
  String option1ImageUrl,
  String option2ImageUrl,
  String option3ImageUrl,
  String option4ImageUrl,
}) {
  ImageUploader imageUploader = ImageUploader();
  imageUploader.userId = teacherId;
  imageUploader.quizId = quizId;
  imageUploader.questionId = questionId;

  if(questionImageUrl != null ) {
    // Delete Question image in storage
    imageUploader.field = "question";
    imageUploader.deleteUploaded();
  }
  if(option1ImageUrl != null ) {
    // Delete option1 image in storage
    imageUploader.field = "option1";
    imageUploader.deleteUploaded();
  }
  if(option2ImageUrl != null ) {
    // Delete option2 image in storage
    imageUploader.field = "option2";
    imageUploader.deleteUploaded();
  }
  if(option3ImageUrl != null ) {
    // Delete option3 image in storage
    imageUploader.field = "option3";
    imageUploader.deleteUploaded();
  }
  if(option4ImageUrl != null ) {
    // Delete option4 image in storage
    imageUploader.field = "option4";
    imageUploader.deleteUploaded();
  }
}