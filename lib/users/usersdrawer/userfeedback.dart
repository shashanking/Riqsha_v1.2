import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:wiredash/wiredash.dart';

class UserFeedback extends StatefulWidget {
  @override
  _UserFeedbackState createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  TextEditingController feedbacktext = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(getTranslated(context, "FEEDBACK")),
      ),
      body: Center(
        child: Container(
          // height: 200.0,
          child: RaisedButton(
            color: Colors.green,
            onPressed: () {
              Wiredash.of(context).show();
            },
            child: Text(getTranslated(context, "Give Feedback")),
          ),
        ),
      ),
    );
  }
}
