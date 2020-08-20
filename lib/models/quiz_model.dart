class QuizModel {
  String imgURL;
  String topic;
  String description;
  final String quizId;
  int nCorrect;
  int nWrong;
  int nTotal;
  int nNotAttempted;

  QuizModel({this.imgURL, this.topic, this.description, this.quizId, this.nCorrect, this.nWrong, this.nTotal, this.nNotAttempted});
}