import 'package:flutter/material.dart';
import 'package:last_mile_v2/drivers/driversignup/driversignupotp.dart';
import 'package:last_mile_v2/localization/language_constants.dart';

class DriverSignUp extends StatefulWidget {
  static const String idScreen = "driverregister";
  @override
  _DriverSignUpState createState() => _DriverSignUpState();
}

class _DriverSignUpState extends State<DriverSignUp> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'Sign Up with Phone')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  getTranslated(context, 'Phone Authentication'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40, right: 10, left: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'Phone Number'),
                  prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('+91'),
                  ),
                ),
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: _controller,
              ),
            )
          ]),
          Container(
            margin: EdgeInsets.all(10),
            width: double.infinity,
            child: FlatButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DriverSignUpOTP(_controller.text)));
              },
              child: Text(
                getTranslated(context, 'Next'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}