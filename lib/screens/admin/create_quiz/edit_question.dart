import 'dart:io';
import 'package:q_and_a/models/question_model.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditQuestion extends StatefulWidget {

  final String quizId;
  final Question questionModel;
  final QuizModel quizModel;
  final String teacherId;
  EditQuestion({this.quizId, this.questionModel, this.quizModel, this.teacherId});

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {

  final _formKey = GlobalKey<FormState>();
  DatabaseService databaseService = new DatabaseService();
  final picker = ImagePicker();

  String loadingText;
  // String userId;
  bool _isLoading = false;
  bool isButtonEnabled = true;

  _editQuestion(String userId) async {
    if(_formKey.currentState.validate()){
      setState(() {
        _isLoading = true;
        loadingText = "Editing question";
      });

      String questionId = widget.questionModel.questionId;
      Map<String,dynamic> questionData = {
        "question" : widget.questionModel.question,
        "option1" : widget.questionModel.option1,
        "option2" : widget.questionModel.option2,
        "option3" : widget.questionModel.option3,
        "option4" : widget.questionModel.option4,
        "questionImageUrl" : widget.questionModel.questionImageUrl,
        "option1ImageUrl" : widget.questionModel.option1ImageUrl,
        "option2ImageUrl" : widget.questionModel.option2ImageUrl,
        "option3ImageUrl" : widget.questionModel.option3ImageUrl,
        "option4ImageUrl" : widget.questionModel.option4ImageUrl,
        "questionImageCaption" : widget.questionModel.questionImageCaption,
        "option1ImageCaption" : widget.questionModel.option1ImageCaption,
        "option2ImageCaption" : widget.questionModel.option2ImageCaption,
        "option3ImageCaption" : widget.questionModel.option3ImageCaption,
        "option4ImageCaption" : widget.questionModel.option4ImageCaption,
        "questionId" : widget.questionModel.questionId,
        "isTrueOrFalseType" : widget.questionModel.isTrueOrFalseType,
        "trueOrFalseAnswer" : widget.questionModel.trueOrFalseAnswer,
      };

      await databaseService.addQuestionDetails(
        questionData: questionData,
        quizId: widget.quizId,
        questionId: questionId,
        userId: userId
      ).then((val){
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
      });
    }
  }

  Future<void> _pickImage(ImageSource source, fieldsToUploadImage field, String userId) async {

    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File croppedImage = await _cropImage(File(pickedFile.path), field);
      ImageUploader imageUploader = ImageUploader();
      imageUploader.file = croppedImage;
      imageUploader.field = enumToString(field);
      imageUploader.quizId = widget.quizId;
      imageUploader.questionId = widget.questionModel.questionId;
      imageUploader.userId = userId;
      setState(() {
        isButtonEnabled = false;
        loadingText = "Loading image";
      });
      imageUploader.startUpload().then((value)  {
        setState(() {

          switch (field) {
            case fieldsToUploadImage.question :
              widget.questionModel.questionImageUrl = value;
              break;
            case fieldsToUploadImage.option1 :
              widget.questionModel.option1ImageUrl = value;
              break;
            case fieldsToUploadImage.option2 :
              widget.questionModel.option2ImageUrl = value;
              break;
            case fieldsToUploadImage.option3 :
              widget.questionModel.option3ImageUrl = value;
              break;
            case fieldsToUploadImage.option4 :
              widget.questionModel.option4ImageUrl = value;
              break;
            case fieldsToUploadImage.quizzes:
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

  Future<File> _cropImage(File image, fieldsToUploadImage field) async {
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
      case fieldsToUploadImage.question :
        return croppedImage ?? image;
        break;
      case fieldsToUploadImage.option1 :
        return croppedImage ?? image;
        break;
      case fieldsToUploadImage.option2 :
        return croppedImage ?? image;
        break;
      case fieldsToUploadImage.option3 :
        return croppedImage ?? image;
        break;
      case fieldsToUploadImage.option4 :
        return croppedImage ?? image;
        break;
      default:
        return null;
        break;
    }

  }

  void _clearImage(fieldsToUploadImage field, String userId) {
    ImageUploader imageUploader = ImageUploader();
    imageUploader.field = enumToString(field);
    imageUploader.userId = userId;
    imageUploader.quizId = widget.quizId;
    imageUploader.questionId = widget.questionModel.questionId;
    imageUploader.deleteUploaded();

    setState(() {

      switch (field) {
        case fieldsToUploadImage.question :
          widget.questionModel.questionImageUrl = null;
          break;
        case fieldsToUploadImage.option1 :
          widget.questionModel.option1ImageUrl = null;
          break;
        case fieldsToUploadImage.option2 :
          widget.questionModel.option2ImageUrl = null;
          break;
        case fieldsToUploadImage.option3 :
          widget.questionModel.option3ImageUrl = null;
          break;
        case fieldsToUploadImage.option4 :
          widget.questionModel.option4ImageUrl = null;
          break;
        case fieldsToUploadImage.quizzes:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);

    return Scaffold(
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
      body: _isLoading || !isButtonEnabled ? Loading(loadingText: loadingText,) : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            child: Column(
              children: <Widget>[
                widget.questionModel.questionImageUrl != null ? Align(child: Text("Question", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                widget.questionModel.questionImageUrl != null ? CachedNetworkImage(
                  useOldImageOnUrlChange: false,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  imageUrl: widget.questionModel.questionImageUrl,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, e) => Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    alignment: Alignment.topCenter,
                    child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                  ),
                ) : Container(),
                widget.questionModel.questionImageUrl != null ? Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    initialValue: widget.questionModel.questionImageCaption != null ? widget.questionModel.questionImageCaption : null,
                    decoration: InputDecoration(
                      hintText: "Caption (Question)",
                      helperText: "Optional",
                    ),
                    onChanged: (val) {
                      widget.questionModel.questionImageCaption = val;
                    },
                  ),
                ) : Container(),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: widget.questionModel.question,
                      validator: (val) => val.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(
                        hintText: "Question",
                        helperText: "Question",
                        contentPadding: widget.questionModel.questionImageUrl != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                      ),
                      onChanged: (val) {
                        widget.questionModel.question = val;
                      },
                    ),
                    textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, fieldsToUploadImage.question, user.uid)),
                    textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, fieldsToUploadImage.question, user.uid)),
                    widget.questionModel.questionImageUrl != null ? textFieldStackButtonTimes(() =>  _clearImage(fieldsToUploadImage.question, user.uid)) : Container(),
                  ],
                ),

                widget.questionModel.isTrueOrFalseType ? Column(
                  children: <Widget>[
                    RadioListTile(
                      value: true,
                      groupValue: widget.questionModel.trueOrFalseAnswer,
                      onChanged: (newValue) => setState(() => widget.questionModel.trueOrFalseAnswer = newValue),
                      title: Text("True"),
                    ),
                    RadioListTile(
                      value: false,
                      groupValue: widget.questionModel.trueOrFalseAnswer,
                      onChanged: (newValue) => setState(() => widget.questionModel.trueOrFalseAnswer = newValue),
                      title: Text("False"),
                    )
                  ],
                ) : Column(
                  children: [
                    SizedBox(height: 30,),
                    widget.questionModel.option1ImageUrl != null ? Align(child: Text("Correct Option", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                    widget.questionModel.option1ImageUrl != null ? CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.questionModel.option1ImageUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, e) => Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        alignment: Alignment.topCenter,
                        child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                      ),
                    ) : Container(),
                    widget.questionModel.option1ImageUrl != null ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: widget.questionModel.option1ImageCaption != null ? widget.questionModel.option1ImageCaption : null,
                        decoration: InputDecoration(
                          hintText: "Caption (Option 1)",
                          helperText: "Optional",
                        ),
                        onChanged: (val) {
                          widget.questionModel.option1ImageCaption = val;
                        },
                      ),
                    ) : Container(),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.questionModel.option1,
                          validator: (val) => val.isEmpty ? "Enter Option" : null,
                          decoration: InputDecoration(
                            hintText: "Correct Option",
                            helperText: "Correct Option",
                            contentPadding: widget.questionModel.option1ImageUrl != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                          ),
                          onChanged: (val) {
                            widget.questionModel.option1 = val;
                          },
                        ),
                        textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, fieldsToUploadImage.option1, user.uid)),
                        textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, fieldsToUploadImage.option1, user.uid)),
                        widget.questionModel.option1ImageUrl != null ? textFieldStackButtonTimes(() =>  _clearImage(fieldsToUploadImage.option1, user.uid)) : Container(),
                      ],
                    ),

                    widget.questionModel.option2ImageUrl != null || widget.questionModel.option1ImageUrl != null? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                    widget.questionModel.option2ImageUrl != null ? Align(child: Text("Option 2", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                    widget.questionModel.option2ImageUrl != null ? CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.questionModel.option2ImageUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, e) => Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        alignment: Alignment.topCenter,
                        child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                      ),
                    ) : Container(),
                    widget.questionModel.option2ImageUrl != null ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: widget.questionModel.option2ImageCaption != null ? widget.questionModel.option2ImageCaption : null,
                        decoration: InputDecoration(
                          hintText: "Caption (Option 2)",
                          helperText: "Optional",
                        ),
                        onChanged: (val) {
                          widget.questionModel.option2ImageCaption = val;
                        },
                      ),
                    ) : Container(),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.questionModel.option2,
                          validator: (val) => val.isEmpty ? "Enter Option" : null,
                          decoration: InputDecoration(
                            hintText: "Option 2",
                            helperText: "Option 2",
                            contentPadding: widget.questionModel.option2ImageUrl != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                          ),
                          onChanged: (val) {
                            widget.questionModel.option2 = val;
                          },
                        ),
                        textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, fieldsToUploadImage.option2, user.uid)),
                        textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, fieldsToUploadImage.option2, user.uid)),
                        widget.questionModel.option2ImageUrl != null ? textFieldStackButtonTimes(() =>  _clearImage(fieldsToUploadImage.option2, user.uid)) : Container(),
                      ],
                    ),

                    widget.questionModel.option3ImageUrl != null || widget.questionModel.option2ImageUrl != null? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                    widget.questionModel.option3ImageUrl != null ? Align(child: Text("Option 3", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                    widget.questionModel.option3ImageUrl != null ? CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.questionModel.option3ImageUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, e) => Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        alignment: Alignment.topCenter,
                        child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                      ),
                    ) : Container(),
                    widget.questionModel.option3ImageUrl != null ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: widget.questionModel.option3ImageCaption != null ? widget.questionModel.option3ImageCaption : null,
                        decoration: InputDecoration(
                          hintText: "Caption (Option 3)",
                          helperText: "Optional",
                        ),
                        onChanged: (val) {
                          widget.questionModel.option3ImageCaption = val;
                        },
                      ),
                    ) : Container(),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.questionModel.option3,
                          validator: (val) => val.isEmpty ? "Enter Option" : null,
                          decoration: InputDecoration(
                            hintText: "Option 3",
                            helperText: "Option 3",
                            contentPadding: widget.questionModel.option3ImageUrl != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                          ),
                          onChanged: (val) {
                            widget.questionModel.option3 = val;
                          },
                        ),
                        textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, fieldsToUploadImage.option3, user.uid)),
                        textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, fieldsToUploadImage.option3, user.uid)),
                        widget.questionModel.option3ImageUrl != null ? textFieldStackButtonTimes(() =>  _clearImage(fieldsToUploadImage.option3, user.uid)) : Container(),
                      ],
                    ),

                    widget.questionModel.option4ImageUrl != null || widget.questionModel.option3ImageUrl != null? SizedBox(height: 40.0,) : SizedBox(height: 8.0,),
                    widget.questionModel.option4ImageUrl != null ? Align(child: Text("Option 4", style: TextStyle(fontSize: 22, color: Colors.black54),), alignment: Alignment.topLeft,) : Container(),
                    widget.questionModel.option4ImageUrl != null ? CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.questionModel.option4ImageUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, e) => Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        alignment: Alignment.topCenter,
                        child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                      ),
                    ) : Container(),
                    widget.questionModel.option4ImageUrl != null ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: widget.questionModel.option4ImageCaption != null ? widget.questionModel.option4ImageCaption : null,
                        decoration: InputDecoration(
                          hintText: "Caption (Option 4)",
                          helperText: "Optional",
                        ),
                        onChanged: (val) {
                          widget.questionModel.option4ImageCaption = val;
                        },
                      ),
                    ) : Container(),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: widget.questionModel.option4,
                          validator: (val) => val.isEmpty ? "Enter Option" : null,
                          decoration: InputDecoration(
                            hintText: "Option 4",
                            helperText: "Option 4",
                            contentPadding: widget.questionModel.option4ImageUrl != null ? textFieldStackContentPaddingWithTimes : textFieldStackContentPaddingWithoutTimes,
                          ),
                          onChanged: (val) {
                            widget.questionModel.option4 = val;
                          },
                        ),
                        textFieldStackButtonCamera(() => _pickImage(ImageSource.camera, fieldsToUploadImage.option4, user.uid)),
                        textFieldStackButtonImages(() => _pickImage(ImageSource.gallery, fieldsToUploadImage.option4, user.uid)),
                        widget.questionModel.option4ImageUrl != null ? textFieldStackButtonTimes(() =>  _clearImage(fieldsToUploadImage.option4, user.uid)) : Container(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                blueButton(context: context,label: "Edit This Question", onPressed: () {
                  _editQuestion(user.uid);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
