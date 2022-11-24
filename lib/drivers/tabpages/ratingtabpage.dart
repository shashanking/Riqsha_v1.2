import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class DriverRatingTabPage extends StatefulWidget {
  @override
  _DriverRatingTabPageState createState() => _DriverRatingTabPageState();
}

class _DriverRatingTabPageState extends State<DriverRatingTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0),
              Text(
                getTranslated(context, "Your's Rating"),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 22.0),
              Divider(
                height: 2.0,
                thickness: 2.0,
              ),
              SizedBox(height: 16.0),

              // rating for driver
              SmoothStarRating(
                rating: driverstarCounter,
                color: Colors.yellow,
                allowHalfRating: true,
                starCount: 5,
                size: 45,
                isReadOnly: true,
                
              ),
              SizedBox(height: 14.0),

              Text(
                driverTitle,
                style: TextStyle(
                  fontSize: 55.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 14.0),
            ],
          ),
        ),
      ),
    );
  }
}
