import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_and_a/models/quiz_model.dart';
import 'package:q_and_a/models/user_model.dart';
import 'package:q_and_a/screens/admin/create_quiz/add_question.dart';
import 'package:q_and_a/screens/shared_screens/loading.dart';
import 'package:q_and_a/screens/shared_screens/quiz_details_tile.dart';
import 'package:q_and_a/services/database.dart';
import 'package:q_and_a/services/image_uploader.dart';
import 'package:q_and_a/shared/constants.dart';
import 'package:q_and_a/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CreateQuiz extends StatefulWidget {

  final TeacherModel currentUser;
  final bool isFromEditQuiz;
  final QuizModel quizModelToEdit;

  CreateQuiz({this.currentUser, this.isFromEditQuiz, this.quizModelToEdit});

  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {

  final _formKey = GlobalKey<FormState>();
  QuizModel quizModel = QuizModel();
  DatabaseService databaseService = new DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final picker = ImagePicker();
  var uuid = Uuid();

  String quizId = "";
  File quizImage;
  String loadingText;
  bool _isLoading = false;

  _updateQuiz() async {
    Map<String,String> quizData;
    if(_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
        loadingText = "Updating";
      });

      if(quizModel.imgURL == null && quizImage == null) {
        quizData = {
          "topic" : quizModel.topic,
          "description" : quizModel.description,
          "imgURL" : null,
        };
      } else if(quizImage != null) {
        ImageUploader imageUploader = ImageUploader();
        imageUploader.file = quizImage;
        imageUploader.field = enumToString(fieldsToUploadImage.quizzes);
        imageUploader.quizId = quizId;
        imageUploader.userId = widget.currentUser.uid;
        imageUploader.isFromCreateQuiz = true;
        await imageUploader.startUpload().then((value)  {
          quizData = {
            "topic" : quizModel.topic,
            "description" : quizModel.description,
            "imgURL" : value,
          };
        });
      } else {
        quizData = {
          "topic" : quizModel.topic,
          "description" : quizModel.description,
          "imgURL" : quizModel.imgURL,
        };
      }
    }

    await databaseService.updateQuizDetails(
      userId: widget.currentUser.uid,
      quizId: quizModel.quizId,
      quizData: quizData,
    ).then((value) {
      Navigator.pop(context);
    });
  }

  _createQuiz() async {
    Map<String,String> quizData;

    if(_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
        loadingText = "Loading Quiz Image";
      });

      if(quizImage != null) {
        ImageUploader imageUploader = ImageUploader();
        imageUploader.file = quizImage;
        imageUploader.field = enumToString(fieldsToUploadImage.quizzes);
        imageUploader.quizId = quizId;
        imageUploader.userId = widget.currentUser.uid;
        imageUploader.isFromCreateQuiz = true;
        await imageUploader.startUpload().then((value)  {
          quizData = {
            "quizId" : quizId,
            "topic" : quizModel.topic,
            "description" : quizModel.description,
            "imgURL" : value,
          };
        });
      } else {
        quizData = {
          "quizId" : quizId,
          "topic" : quizModel.topic,
          "description" : quizModel.description,
          "imgURL" : null,
        };
      }

      setState(() {
        loadingText = "Adding Quiz - ${quizModel.topic}";
      });

      await databaseService.addQuizDetails(
          quizData: quizData,
          quizId: quizId,
          userId: widget.currentUser.uid
      ).then((val){
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => AddQuestion(quizId: quizId, quizTopic: quizModel.topic,)
        ));
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {

    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File croppedImage = await _cropImage(File(pickedFile.path));
      setState(() {
        quizImage = croppedImage;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

  }

  Future<File> _cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 50,
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.blueAccent,
          backgroundColor: Colors.black38,
          toolbarWidgetColor: Colors.black54,
          activeControlsWidgetColor: Colors.blueAccent,
          statusBarColor: Colors.black54
      ),
    );

    setState(() {
      quizImage = croppedImage;
    });
    return croppedImage ?? image;
  }

  void _clearImage() {
    ImageUploader imageUploader = ImageUploader();
    imageUploader.field = enumToString(fieldsToUploadImage.quizzes);
    imageUploader.quizId = quizId;
    imageUploader.userId = widget.currentUser.uid;
    imageUploader.isFromCreateQuiz = true;
    imageUploader.deleteUploaded();

    setState(() {
      quizImage = null;
    });
  }

  @override
  void initState() {
    if(widget.isFromEditQuiz == true) {
      quizModel.topic = widget.quizModelToEdit.topic;
      quizModel.description = widget.quizModelToEdit.description;
      quizModel.quizId = widget.quizModelToEdit.quizId;
      quizModel.imgURL = widget.quizModelToEdit.imgURL;
    } else {
      quizModel.topic = "";
      quizModel.description = "";
      quizId = uuid.v1();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

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
      body: _isLoading ? Loading(loadingText: loadingText,) : SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    widget.isFromEditQuiz == true ? "Edit Quiz" : "Preview",
                    style: TextStyle(fontSize: 25.0, color: Colors.black54),
                  ),
                  SizedBox(height: 5,),
                  QuizDetailsTile(
                    quizModel: quizModel,
                    quizImage: quizImage,
                    isPreview: true,
                  )
                ],
              ),
              SizedBox(height: 15,),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Topic" : null,
                      initialValue: quizModel.topic,
                      decoration: InputDecoration(
                          hintText: "Quiz Topic"
                      ),
                      onChanged: (val) {
                        setState(() {
                          quizModel.topic = val;
                        });
                      },
                    ),
                    SizedBox(height: 8,),
                    TextFormField(
                      validator: (val) => val.isEmpty ? "Enter Description" : null,
                      initialValue: quizModel.description,
                      decoration: InputDecoration(
                          hintText: "Quiz Description"
                      ),
                      onChanged: (val) {
                        setState(() {
                          quizModel.description = val;
                        });
                      },
                    ),
                    SizedBox(height: 25,),
                    // widget.isFromEditQuiz == true ? Container() :
                    Container(
                      child: Column(
                        children: [
                          Text("Edit background image", style: TextStyle(fontSize: 20.0, color: Colors.black.withOpacity(0.7))),
                          SizedBox(height: 5,),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FlatButton.icon(
                                  onPressed: () {
                                    _pickImage(ImageSource.gallery);
                                  },
                                  icon: FaIcon(FontAwesomeIcons.images, size: 22.0, color: Colors.blueAccent.withOpacity(0.9),),
                                  label: Text("Gallery", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7))),
                                ),
                                quizImage != null ? FlatButton.icon(
                                  onPressed: () {
                                    _clearImage();
                                  },
                                  icon: FaIcon(FontAwesomeIcons.undoAlt, size: 22.0, color: Colors.blueAccent.withOpacity(0.9),),
                                  label: Text("Undo", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7))),
                                ) : Container(),
                                FlatButton.icon(
                                  onPressed: () {
                                    _pickImage(ImageSource.camera);
                                  },
                                  icon: FaIcon(FontAwesomeIcons.camera, size: 22.0, color: Colors.blueAccent.withOpacity(0.9),),
                                  label: Text("Camera", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7))),
                                ),
                              ],
                            ),
                          ),

                          quizModel.topic != "" ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            width: MediaQuery.of(context).size.width - 40,
                            child: FlatButton.icon(
                              onPressed: () async {
                                String url = "https://www.google.com/images?q=${quizModel.topic}";
                                if(await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  final snackBar = SnackBar(
                                    content: Text("There was an error launching \"$url\"", style: TextStyle(fontSize: 15.0),),
                                    backgroundColor: Colors.blueAccent,
                                  );
                                  _scaffoldKey.currentState.showSnackBar(snackBar);
                                }
                              },
                              splashColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              icon: FaIcon(FontAwesomeIcons.search, size: 30.0, color: Colors.blueAccent.withOpacity(0.9),),
                              label: Flexible(
                                fit: FlexFit.loose,
                                child: Text("Search Google images for \"${quizModel.topic}\"",
                                  style: TextStyle(fontSize: 15), overflow: TextOverflow.fade, softWrap: false,),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    SizedBox(height: 15,),
                    blueButton(
                      context: context,
                      label: widget.isFromEditQuiz == true ? "Update Quiz" : "Create Quiz",
                      onPressed: widget.isFromEditQuiz == true ?  _updateQuiz : _createQuiz,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
