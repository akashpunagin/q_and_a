import 'dart:io';
import 'package:q_and_a/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class SendEmail {
  String teacherEmail;
  int nWrong;
  int nCorrect;
  int nTotal;
  int nNotAttempted;
  String topic;
  String studentName;
  String studentId;

  SendEmail({this.teacherEmail, this.nWrong, this.nCorrect, this.nTotal, this.nNotAttempted, this.topic, this.studentName});

  sendEmailQuizSubmit() async {
    final pdf = pw.Document();

    // Create PDF File
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            margin: pw.EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: pw.Column(
                children: <pw.Widget>[
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: <pw.Widget>[
                      pw.Text("QandA", style: pw.TextStyle(fontSize: 40.0, decoration: pw.TextDecoration.underline)),
                      pw.SizedBox(height: 10,),
                      pw.Text("Quiz Submission by $studentName", style: pw.TextStyle(fontSize: 20.0,)),
                    ],
                  ),
                  pw.SizedBox(height: 30.0,),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text("Name : $studentName", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                        pw.Text("Topic : $topic", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                        pw.Text("Total Questions : $nTotal", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                        pw.Text("Correctly Answered : $nCorrect", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                        pw.Text("Incorrectly Answered : $nWrong", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                        pw.Text("Not Attempted : $nNotAttempted", style: pw.TextStyle(fontSize: 20.0), textAlign: pw.TextAlign.left),
                      ]
                    ),
                  ),
                ]
            ),
          );
        }
      )
    );

    // Save PDF File
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/email_attachment.pdf");
    await file.writeAsBytes(pdf.save());

    // Creating body of mail
    String bodyText = "Respected Sir / Madam,<br/>Please find the attachment of my results on quiz - $topic.<br/><br/>Thank you<br/><br/>$studentName";

    final MailOptions mailOptions = MailOptions(
      body: bodyText,
      subject: "QandA - Quiz submission by $studentName",
      recipients: ['$teacherEmail'],
      isHTML: true,
      attachments: ['${output.path}/email_attachment.pdf'],
    );

    try {
      await FlutterMailer.send(mailOptions);
    } catch (e) {
      print(e.toString());
    }
  }

  sendEmailProgress() async {

    DatabaseService databaseService = DatabaseService();
    final DateFormat formatterDate = DateFormat.MMMMd();
    final DateFormat formatterTime = DateFormat.Hm();

    QuerySnapshot result = await databaseService.getStudentProgress(userId: studentId);

    // Creating List of List (table)
    List<List<String>> titles = List();
    titles.add(<String>[" ","Teacher", "Topic", "Total Questions", "Correct", "Wrong", "Not Attempted", "Time of Day"]);
    int nTotalQuestions = 0;
    int nTotalCorrect = 0;
    int nTotalWrong = 0;
    int nTotalNotAttempted = 0;
    for ( var index = 0; index < result.docs.length; index++) {
      final String formattedDate = formatterDate.format(result.docs[index].data()['createAt'].toDate());
      final String formattedTime = formatterTime.format(result.docs[index].data()['createAt'].toDate());

      List<String> row = <String>[
        (index+1).toString(),
        result.docs[index].data()['teacher'],
        result.docs[index].data()['topic'],
        result.docs[index].data()['nTotal'].toString(),
        result.docs[index].data()['nCorrect'].toString(),
        result.docs[index].data()['nWrong'].toString(),
        result.docs[index].data()['nNotAttempted'].toString(),
        "$formattedTime\n$formattedDate",
      ];
      titles.add(row);

      nTotalQuestions = nTotalQuestions + result.docs[index].data()['nTotal'];
      nTotalCorrect = nTotalCorrect + result.docs[index].data()['nCorrect'];
      nTotalWrong = nTotalWrong + result.docs[index].data()['nWrong'];
      nTotalNotAttempted = nTotalNotAttempted + result.docs[index].data()['nNotAttempted'];
    }
    titles.add(<String>["Total", " ", " ", nTotalQuestions.toString(), nTotalCorrect.toString(), nTotalWrong.toString(), nTotalNotAttempted.toString(), " "]);


    final pdf = pw.Document();

    // Creating PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Container(
            alignment: pw.Alignment.topCenter,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: <pw.Widget>[
                pw.Text("QandA", style: pw.TextStyle(fontSize: 40.0, decoration: pw.TextDecoration.underline)),
                pw.SizedBox(height: 10,),
                pw.Text("Progress Submission by $studentName", style: pw.TextStyle(fontSize: 20.0,)),
              ],
            )
          ),
          pw.SizedBox(height: 30.0,),
          pw.Table.fromTextArray(context: context, data: titles),
        ]
      )
    );

    // Save PDF File
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/email_attachment.pdf");
    await file.writeAsBytes(pdf.save());

    String bodyText = "Respected Sir / Madam,<br/>I am pleased to share my progress on QandA.<br/><br/>Please find the attachment below.<br/><br/>Thank You<br/><br/>$studentName";

    final MailOptions mailOptions = MailOptions(
      body: bodyText,
      subject: "QandA - Progress submission by $studentName",
      recipients: ['$teacherEmail'],
      isHTML: true,
      attachments: ['${output.path}/email_attachment.pdf'],
    );

    try {
      await FlutterMailer.send(mailOptions);
    } catch (e) {
      print(e.toString());
    }

  }

}
