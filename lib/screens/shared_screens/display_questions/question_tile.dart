import 'package:q_and_a/models/option_model.dart';
import 'package:q_and_a/models/question_model.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/screens/admin/create_quiz/edit_question.dart';
import 'package:q_and_a/screens/shared_screens/display_questions/option_tile.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:q_and_a/shared/functions.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuestionTile extends StatefulWidget {

  final Question questionModel;
  final int index;
  final QuizModel quizModel;
  final bool fromStudent;
  final String teacherId;
  final Function setDisplayQuestionsState;
  final Function showEditSnackBar;
  QuestionTile({this.showEditSnackBar, this.questionModel, this.index, this.quizModel, this.fromStudent, this.teacherId, this.setDisplayQuestionsState});

  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {

  DatabaseService databaseService = DatabaseService();
  List<String> _labels = ["A", "B", "C", "D"];
  List<OptionModel> _options = [];

  Map<String, Color> _colors = {
    "defaultColor" : Colors.transparent,
    "colorIfAnswered" : Colors.yellow[300],
    "colorIfCorrect" : Colors.green[600],
    "colorIfWrong" : Colors.red[500],
  };

  displayDeleteQuestionAlert(BuildContext context) {
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.info,
      title: "Delete Question",
      desc: "Are you sure you want to delete question - \n\"${widget.questionModel.question}\" ?",
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            deleteStorageImagesOfQuiz(
                teacherId: widget.teacherId,
                quizId: widget.quizModel.quizId,
                questionId: widget.questionModel.questionId,
                questionImageUrl: widget.questionModel.questionImageUrl,
                option1ImageUrl: widget.questionModel.option1ImageUrl,
                option2ImageUrl: widget.questionModel.option2ImageUrl,
                option3ImageUrl: widget.questionModel.option3ImageUrl,
                option4ImageUrl: widget.questionModel.option4ImageUrl,
            );
            databaseService.deleteQuestionDetails(
              userId: widget.teacherId,
              quizId: widget.quizModel.quizId,
              questionId: widget.questionModel.questionId,
            );
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Colors.blue[500],
            Colors.blue[400],
          ]),
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Colors.blue[400],
            Colors.blue[500],
          ]),
        )
      ],
    ).show();
  }

  _onMcqOptionTap(int index) {
    if (widget.questionModel.isAnswered != true) {
      setState(() {
        widget.questionModel.isAnswered = true;
        widget.questionModel.selectedOption = _options[index].option;
      });

      if (_options[index].option == widget.questionModel.correctOption) {
        setState(() {
          widget.questionModel.isCorrect = true;
          widget.quizModel.nCorrect ++;
          widget.quizModel.nNotAttempted --;
        });
      } else {
        setState(() {
          widget.questionModel.isCorrect = false;
          widget.quizModel.nWrong++;
          widget.quizModel.nNotAttempted --;
        });
      }
    }
  }

  _onTrueOrFalseOptionTap(bool selectedOption) {
    if (widget.questionModel.isAnswered != true) {
      setState(() {
        widget.questionModel.isAnswered = true;
        widget.questionModel.selectedOption = selectedOption.toString();
      });

      if (selectedOption.toString() == widget.questionModel.trueOrFalseAnswer.toString()) {
        setState(() {
          widget.questionModel.isCorrect = true;
          widget.quizModel.nCorrect ++;
          widget.quizModel.nNotAttempted --;
        });
      } else {
        setState(() {
          widget.questionModel.isCorrect = false;
          widget.quizModel.nWrong++;
          widget.quizModel.nNotAttempted --;
        });
      }
    }
  }

  @override
  void initState() {

    if( !widget.questionModel.isTrueOrFalseType ) {
      OptionModel optionModel1 = OptionModel();
      OptionModel optionModel2 = OptionModel();
      OptionModel optionModel3 = OptionModel();
      OptionModel optionModel4 = OptionModel();

      optionModel1.option = widget.questionModel.option1;
      optionModel2.option = widget.questionModel.option2;
      optionModel3.option = widget.questionModel.option3;
      optionModel4.option = widget.questionModel.option4;

      optionModel1.optionImageUrl = widget.questionModel.option1ImageUrl;
      optionModel2.optionImageUrl = widget.questionModel.option2ImageUrl;
      optionModel3.optionImageUrl = widget.questionModel.option3ImageUrl;
      optionModel4.optionImageUrl = widget.questionModel.option4ImageUrl;

      optionModel1.optionImageCaption = widget.questionModel.option1ImageCaption;
      optionModel2.optionImageCaption = widget.questionModel.option2ImageCaption;
      optionModel3.optionImageCaption = widget.questionModel.option3ImageCaption;
      optionModel4.optionImageCaption = widget.questionModel.option4ImageCaption;

      setState(() {
        _options = [
          optionModel1,
          optionModel2,
          optionModel3,
          optionModel4,
        ];
        _options.shuffle();
      });

    }


    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      shadowColor: Colors.black,
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: Colors.white70.withOpacity(0.95),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.questionModel.questionImageUrl != null ? CachedNetworkImage(
              imageUrl: widget.questionModel.questionImageUrl,
              imageBuilder: (context, imageProvider) {
                return Column(
                  children: [
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image(
                          image: imageProvider,
                        ),
                      ),
                    ),
                    widget.questionModel.questionImageCaption != null ? Center(
                      child: Container(
                        child: Text(widget.questionModel.questionImageCaption,
                          style: TextStyle(color: Colors.black54), textAlign: TextAlign.center,
                        ),
                      ),
                    ) : Container(),
                  ],
                );
              },
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, e) => Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                alignment: Alignment.topCenter,
                child: Text("Error loading image", style: TextStyle(fontSize: 18),),
              ),
            ) : Container(),
            SizedBox(height: 5,),
            Text("Q${widget.index+1}. ${widget.questionModel.question}", style: TextStyle(fontSize: 22.0),),
            widget.questionModel.questionImageUrl != null && !widget.questionModel.isTrueOrFalseType? SizedBox(height: 40,) : Container(),
            widget.questionModel.isTrueOrFalseType ? Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      _onTrueOrFalseOptionTap(true);
                    },
                    child: OptionTile(
                      option: "True",
                      label: _labels[0],
                      optionColor: widget.questionModel.isAnswered ?
                      widget.questionModel.selectedOption == true.toString() ?
                      widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                          : _colors['colorIfWrong']
                          : _colors['colorIfAnswered']
                          : _colors['defaultColor'],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _onTrueOrFalseOptionTap(false);
                    },
                    child: OptionTile(
                      option: "False",
                      label: _labels[1],
                      optionColor: widget.questionModel.isAnswered ?
                      widget.questionModel.selectedOption == false.toString() ?
                      widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                          : _colors['colorIfWrong']
                          : _colors['colorIfAnswered']
                          : _colors['defaultColor'],
                    ),
                  ),
                ],
              ),
            ) : Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _onMcqOptionTap(0);
                  },
                  child: OptionTile(
                    option: _options[0].option,
                    label: _labels[0],
                    optionImageUrl: _options[0].optionImageUrl,
                    optionCaption: _options[0].optionImageCaption,
                    optionColor: widget.questionModel.isAnswered ?
                    widget.questionModel.selectedOption == _options[0].option ?
                    widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                        : _colors['colorIfWrong']
                        : _colors['colorIfAnswered']
                        : _colors['defaultColor'],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onMcqOptionTap(1);
                  },
                  child: OptionTile(
                    option: _options[1].option,
                    label: _labels[1],
                    optionImageUrl: _options[1].optionImageUrl,
                    optionCaption: _options[1].optionImageCaption,
                    optionColor: widget.questionModel.isAnswered ?
                    widget.questionModel.selectedOption == _options[1].option ?
                    widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                        : _colors['colorIfWrong']
                        : _colors['colorIfAnswered']
                        : _colors['defaultColor'],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onMcqOptionTap(2);
                  },
                  child: OptionTile(
                    option: _options[2].option,
                    label: _labels[2],
                    optionImageUrl: _options[2].optionImageUrl,
                    optionCaption: _options[2].optionImageCaption,
                    optionColor: widget.questionModel.isAnswered ?
                    widget.questionModel.selectedOption == _options[2].option ?
                    widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                        : _colors['colorIfWrong']
                        : _colors['colorIfAnswered']
                        : _colors['defaultColor'],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onMcqOptionTap(3);
                  },
                  child: OptionTile(
                    option: _options[3].option,
                    label: _labels[3],
                    optionImageUrl: _options[3].optionImageUrl,
                    optionCaption: _options[3].optionImageCaption,
                    optionColor: widget.questionModel.isAnswered ?
                    widget.questionModel.selectedOption == _options[3].option ?
                    widget.questionModel.isCorrect ? _colors['colorIfCorrect']
                        : _colors['colorIfWrong']
                        : _colors['colorIfAnswered']
                        : _colors['defaultColor'],
                  ),
                ),
              ],
            ),

            widget.fromStudent != true ? Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton.icon(
                    onPressed: () {
                      displayDeleteQuestionAlert(context);
                    },
                    icon: FaIcon(FontAwesomeIcons.trash, size: 20.0, color: Colors.black54,),
                    label: Text("Delete", style: TextStyle(fontSize: 16, color: Colors.black54),),
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditQuestion(
                            quizId: widget.quizModel.quizId,
                            questionModel: widget.questionModel,
                            quizModel: widget.quizModel,
                            teacherId: widget.teacherId,
                          )
                      )).then((value) {
                        if(value == true) {
                          widget.showEditSnackBar(widget.index);
                        }
                      });
                    },
                    icon: FaIcon(FontAwesomeIcons.pencilAlt, size: 20.0, color: Colors.blueAccent,),
                    label: Text("Edit", style: TextStyle(fontSize: 16, color: Colors.blueAccent),),
                  ),
                ],
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
