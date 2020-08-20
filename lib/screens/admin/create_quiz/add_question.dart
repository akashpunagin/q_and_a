import 'dart:io';

import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddQuestion extends StatefulWidget {

  final String quizId;
  final String quizTopic;
  AddQuestion({this.quizId, this.quizTopic});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {

  final _formKey = GlobalKey<FormState>();
  DatabaseService databaseService = new DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var uuid = Uuid();
  final picker = ImagePicker();

  File _imageQuestion;
  File _imageOption1;
  File _imageOption2;
  File _imageOption3;
  File _imageOption4;

  String question = "";
  String option1 = "";
  String option2 = "";
  String option3 = "";
  String option4 = "";
  String userId = "";
  String questionImageUrl;
  String option1ImageUrl;
  String option2ImageUrl;
  String option3ImageUrl;
  String option4ImageUrl;
  String questionImageCaption;
  String option1ImageCaption;
  String option2ImageCaption;
  String option3ImageCaption;
  String option4ImageCaption;
  String questionId = "";
  bool _isLoading = false;
  List<String> questionType = ["Multiple Choice Question", "True / False"];
  String selectedQuestionType;
  bool trueOrFalse = true;
  bool isButtonEnabled = true;

  _addQuestion() async {
    if(_formKey.currentState.validate()){
      setState(() {
        _isLoading = true;
        _imageQuestion = null;
        _imageOption1 = null;
        _imageOption2 = null;
        _imageOption3 = null;
        _imageOption4 = null;
      });

      Map<String,dynamic> questionData = {
        "question" : question,
        "option1" : option1,
        "option2" : option2,
        "option3" : option3,
        "option4" : option4,
        "questionImageUrl" : questionImageUrl,
        "option1ImageUrl" : option1ImageUrl,
        "option2ImageUrl" : option2ImageUrl,
        "option3ImageUrl" : option3ImageUrl,
        "option4ImageUrl" : option4ImageUrl,
        "questionImageCaption" : questionImageCaption,
        "option1ImageCaption" : option1ImageCaption,
        "option2ImageCaption" : option2ImageCaption,
        "option3ImageCaption" : option3ImageCaption,
        "option4ImageCaption" : option4ImageCaption,
        "questionId" : questionId,
        "isTrueOrFalseType" : selectedQuestionType == questionType[0] ? false : true,
        "trueOrFalseAnswer" : trueOrFalse,
      };

      await databaseService.addQuestionDetails(
          questionData: questionData,
          quizId: widget.quizId,
          questionId: questionId,
          userId: userId).then((val){
        setState(() {
          _isLoading = false;
        });

        final snackBar = SnackBar(
          content: Text("Question - \"$question\" was added to\nQuiz - \"${widget.quizTopic}\"", style: TextStyle(fontSize: 15.0),),
          backgroundColor: Colors.blueAccent,
          action: SnackBarAction(
            label: "Go back",
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    }
  }

  _submit() {
    Navigator.pop(context);
  }


  Future<void> _pickImage(ImageSource source, String field) async {

    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File croppedImage = await _cropImage(File(pickedFile.path), field);
      ImageUploader imageUploader = ImageUploader();
      imageUploader.file = croppedImage;
      imageUploader.field = field;
      imageUploader.quizId = widget.quizId;
      imageUploader.questionId = questionId;
      imageUploader.userId = userId;
      setState(() {
        isButtonEnabled = false;
      });
      imageUploader.startUpload().then((value)  {
        setState(() {

          switch (field) {
            case "question" :
              questionImageUrl = value;
              break;
            case "option1" :
              option1ImageUrl = value;
              break;
            case "option2" :
              option2ImageUrl = value;
              break;
            case "option3" :
              option3ImageUrl = value;
              break;
            case "option4" :
              option4ImageUrl = value;
              break;
          }
          setState(() {
            isButtonEnabled = true;
          });
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

  }

  Future<File> _cropImage(File image, String field) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.blueAccent,
          backgroundColor: Colors.black38,
          toolbarWidgetColor: Colors.black54,
          activeControlsWidgetColor: Colors.blueAccent,
          statusBarColor: Colors.black54
        ),
    );

    switch (field) {
      case "question" :
        setState(() {
          _imageQuestion = croppedImage;
        });
        return croppedImage ?? image;
        break;
      case "option1" :
        setState(() {
          _imageOption1 = croppedImage;
        });
        return croppedImage ?? image;
        break;
      case "option2" :
        setState(() {
          _imageOption2 = croppedImage;
        });
        return croppedImage ?? image;
        break;
      case "option3" :
        setState(() {
          _imageOption3 = croppedImage;
        });
        return croppedImage ?? image;
        break;
      case "option4" :
        setState(() {
          _imageOption4 = croppedImage;
        });
        return croppedImage ?? image;
        break;
      default:
        return null;
        break;
    }

  }

  void _clearImage(String field) {
    ImageUploader imageUploader = ImageUploader();
    imageUploader.field = field;
    imageUploader.userId = userId;
    imageUploader.quizId = widget.quizId;
    imageUploader.questionId = questionId;
    imageUploader.deleteUploaded();

    setState(() {

      switch (field) {
        case "question" :
          _imageQuestion = null;
          questionImageUrl = null;
          break;
        case "option1" :
          _imageOption1 = null;
          option1ImageUrl = null;
          break;
        case "option2" :
          _imageOption2 = null;
          option2ImageUrl = null;
          break;
        case "option3" :
          _imageOption3 = null;
          option3ImageUrl = null;
          break;
        case "option4" :
          _imageOption4 = null;
          option4ImageUrl = null;
          break;
      }
    });
  }


  @override
  void initState() {
    selectedQuestionType = questionType[0];
    questionId = uuid.v1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    setState(() {
      userId = user.uid;
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(
            color: Colors.blue
        ),
      ),
      body: _isLoading ? Loading() : Column(
        children: [
          Expanded(
            flex: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: DropdownButton<String>(
                      iconSize: 40,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      hint: Text("Select type of question"),
                      elevation: 0,
                      dropdownColor: Colors.blueAccent,
                      value: selectedQuestionType,
                      items: questionType.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedQuestionType = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      !isButtonEnabled ? Container(
                        width: (MediaQuery.of(context).size.width/2)-30,
                        child: Center(
                            child: CircularProgressIndicator(),
                        ),
                      ) : blueButton(context: context, label: "Add This Question",
                          onPressed: _addQuestion,
                          width: (MediaQuery.of(context).size.width/2)-30),
                      blueButton(context: context, label: "Submit", onPressed: _submit, width: (MediaQuery.of(context).size.width/2) - 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _imageQuestion != null ? Align(child: Text("Question", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                          _imageQuestion != null ? Container(
                            child: Image.file(_imageQuestion,),
                          ) : Container(),
                          _imageQuestion != null ? Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Caption (Question)",
                                helperText: "Optional",
                              ),
                              onChanged: (val) {
                                questionImageCaption = val;
                              },
                            ),
                          ) : Container(),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextFormField(
                                validator: (val) => val.isEmpty ? "Enter Question" : null,
                                decoration: InputDecoration(
                                  hintText: "Question",
                                  helperText: "Question",
                                  contentPadding: _imageQuestion != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                                ),
                                onChanged: (val) {
                                  question = val;
                                },
                              ),
                              textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, "question")),
                              textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, "question")),
                              _imageQuestion != null ? textFieldStackButtonTimes(() =>  _clearImage("question")) : Container(),
                            ],
                          ),

                          SizedBox(height: 15,),

                          selectedQuestionType == questionType[0] ? Column(
                            children: [
                              SizedBox(height: 30.0,),
                              _imageOption1 != null ? Align(child: Text("Correct Option", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                              _imageOption1 != null ? Container(
                                child: Image.file(_imageOption1),
                              ) : Container(),
                              _imageOption1 != null ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Caption (Option 1)",
                                    helperText: "Optional",
                                  ),
                                  onChanged: (val) {
                                    option1ImageCaption = val;
                                  },
                                ),
                              ) : Container(),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter Option" : null,
                                    decoration: InputDecoration(
                                      hintText: "Correct Option",
                                      helperText: option1 != "" ? "Correct Option" : "",
                                      contentPadding: _imageOption1 != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                                    ),
                                    onChanged: (val) {
                                      option1 = val;
                                    },
                                  ),
                                  textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, "option1")),
                                  textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, "option1")),
                                  _imageOption1 != null ? textFieldStackButtonTimes(() =>  _clearImage("option1")) : Container(),
                                ],
                              ),

                              _imageOption2 != null || _imageOption1 != null ? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                              _imageOption2 != null ? Align(child: Text("Option 2", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                              _imageOption2 != null ? Container(
                                child: Image.file(_imageOption2),
                              ) : Container(),
                              _imageOption2 != null ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Caption (Option 2)",
                                    helperText: "Optional",
                                  ),
                                  onChanged: (val) {
                                    option2ImageCaption = val;
                                  },
                                ),
                              ) : Container(),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter Option" : null,
                                    decoration: InputDecoration(
                                      hintText: "Option 2",
                                      helperText: option2 != "" ? "Option 2" : "",
                                      contentPadding: _imageOption2 != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                                    ),
                                    onChanged: (val) {
                                      option2 = val;
                                    },
                                  ),
                                  textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, "option2")),
                                  textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, "option2")),
                                  _imageOption2 != null ? textFieldStackButtonTimes(() =>  _clearImage("option2")) : Container(),
                                ],
                              ),

                              _imageOption3 != null || _imageOption2 != null? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                              _imageOption3 != null ? Align(child: Text("Option 3", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                              _imageOption3 != null ? Container(
                                child: Image.file(_imageOption3),
                              ) : Container(),
                              _imageOption3 != null ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Caption (Option 3)",
                                    helperText: "Optional",
                                  ),
                                  onChanged: (val) {
                                    option3ImageCaption = val;
                                  },
                                ),
                              ) : Container(),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter Option" : null,
                                    decoration: InputDecoration(
                                      hintText: "Option 3",
                                      helperText: option3 != "" ? "Option 3" : "",
                                      contentPadding: _imageOption3 != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                                    ),
                                    onChanged: (val) {
                                      option3 = val;
                                    },
                                  ),
                                  textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, "option3")),
                                  textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, "option3")),
                                  _imageOption3 != null ? textFieldStackButtonTimes(() =>  _clearImage("option3")) : Container(),
                                ],
                              ),

                              _imageOption4 != null || _imageOption3 != null ? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                              _imageOption4 != null ? Align(child: Text("Option 4", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                              _imageOption4 != null ? Container(
                                child: Image.file(_imageOption4),
                              ) : Container(),
                              _imageOption4 != null ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Caption (Option 4)",
                                    helperText: "Optional",
                                  ),
                                  onChanged: (val) {
                                    option4ImageCaption = val;
                                  },
                                ),
                              ) : Container(),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter Option" : null,
                                    decoration: InputDecoration(
                                      hintText: "Option 4",
                                      helperText: option4 != "" ? "Option 4" : "",
                                      contentPadding: _imageOption4 != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                                    ),
                                    onChanged: (val) {
                                      option4 = val;
                                    },
                                  ),
                                  textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, "option4")),
                                  textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, "option4")),
                                  _imageOption4 != null ? textFieldStackButtonTimes(() =>  _clearImage("option4")) : Container(),
                                ],
                              ),

                              SizedBox(height: 8,),

                            ],
                          ) : Column(
                            children: <Widget>[
                              RadioListTile(
                                value: true,
                                groupValue: trueOrFalse,
                                onChanged: (newValue) => setState(() => trueOrFalse = newValue),
                                title: Text("True"),
                              ),
                              RadioListTile(
                                value: false,
                                groupValue: trueOrFalse,
                                onChanged: (newValue) => setState(() => trueOrFalse = newValue),
                                title: Text("False"),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
