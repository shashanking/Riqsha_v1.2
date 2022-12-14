import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingScreen extends StatefulWidget {
  final String driverId;

  RatingScreen({this.driverId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                "Rate This Driver",
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
                rating: starCounter,
                color: Colors.yellow,
                allowHalfRating: false,
                starCount: 5,
                size: 45,
                onRated: (value) {
                  starCounter = value;
                  if (starCounter == 1) {
                    setState(() {
                      title = "Very Bad";
                    });
                  }
                  if (starCounter == 2) {
                    setState(() {
                      title = "Below Average";
                    });
                  }
                  if (starCounter == 3) {
                    setState(() {
                      title = "Good";
                    });
                  }
                  if (starCounter == 4) {
                    setState(() {
                      title = "Very Good";
                    });
                  }
                  if (starCounter == 5) {
                    setState(() {
                      title = "Excellent";
                    });
                  }
                },
              ),
              SizedBox(height: 14.0),

              Text(
                title,
                style: TextStyle(
                  fontSize: 55.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 14.0),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: () async {
                    double freq = 1;
                    DatabaseReference driverRatingRef = FirebaseDatabase
                        .instance
                        .reference()
                        .child("drivers")
                        .child(widget.driverId)
                        .child("ratings");
                    DatabaseReference numberOfDriverRatingRef = FirebaseDatabase
                        .instance
                        .reference()
                        .child("drivers")
                        .child(widget.driverId)
                        .child("number_of_ratings");

                    numberOfDriverRatingRef.once().then((DataSnapshot snap) {
                      if (snap.value != null) {
                        freq = double.parse(snap.value.toString());
                        freq += 1;
                        numberOfDriverRatingRef.set(freq.toString());
                      } else {
                        numberOfDriverRatingRef.set('1'.toString());
                      }
                    });

                    driverRatingRef.once().then((DataSnapshot snap) {
                      if (snap.value != null) {
                        double oldRatings = double.parse(snap.value.toString());

                        double averageRatings =
                            ((freq - 1) * oldRatings + starCounter) / freq;
                        driverRatingRef.set(averageRatings.toString());
                      } else {
                        driverRatingRef.set(starCounter.toString());
                      }
                    });

                    Navigator.pop(context);
                    // _restartApp();
                  },
                  color: Colors.deepPurpleAccent,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          getTranslated(context, "Submit"),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
