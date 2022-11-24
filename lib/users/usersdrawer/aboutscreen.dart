import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';

class AboutScreen extends StatefulWidget {
  static const String idScreen = "about";
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          // car Icon
          Container(
            height: 220,
            child: Center(
              child: Image.asset('images/uberx.png'),
            ),
          ),

          // Display App Name + Company info
          Padding(
            padding: EdgeInsets.only(top: 30, left: 24, right: 24),
            child: Column(
              children: [
                Text(
                  "RIQSHA",
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  getTranslated(context, "Rickshaw services at your doorsteps through easy booking and payments. Get discounts and offers everytime you book a ride with us. Join our community by booking a ride today! Riqsha also offers wide range of options from regular bookings to full bookings. Also deliver any goods using riqsha."),
                  style: TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 40),

          // go back button
          FlatButton(
            onPressed: () {
              
              Navigator.pop(context);
            },
            color: Colors.green,
            child: Text(
              getTranslated(context, "Go Back"),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
          ),
        ],
      ),
    );
  }
}
