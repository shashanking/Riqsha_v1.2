import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/users/userotp.dart';
import 'package:last_mile_v2/users/usersignup/usersignup.dart';
import 'package:last_mile_v2/users/usersignup/usersignupotp.dart';

class UserLogin extends StatefulWidget {
  static const String idScreen = "userlogin";
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
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
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) => UserSignUp(),
                    // ));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserSignUpOTP(_controller.text)));
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
                        builder: (context) => UserOTP(_controller.text)));
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
