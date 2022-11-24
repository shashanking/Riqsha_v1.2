import 'package:flutter/material.dart';
import 'package:last_mile_v2/drivers/driverotp.dart';
import 'package:last_mile_v2/drivers/driversignup/driversignup.dart';
import 'package:last_mile_v2/drivers/driversignup/driversignupotp.dart';
import 'package:last_mile_v2/localization/language_constants.dart';

class DriverLogin extends StatefulWidget {
  @override
  _DriverLoginState createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'Phone Auth')),
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Container(
                  margin: EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      getTranslated(context, 'Phone Authentication'),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
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
                ),
              ]),
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: FlatButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DriverSignUpOTP(_controller.text)));
                  },
                  child: Text(
                    getTranslated(context, 'Sign Up'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: FlatButton(
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DriverOTP(_controller.text)));
                  },
                  child: Text(
                    getTranslated(context, 'Already have an account? Log In'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
