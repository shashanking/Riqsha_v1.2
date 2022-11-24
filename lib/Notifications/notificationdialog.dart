import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:last_mile_v2/drivers/driverform.dart';
import 'package:last_mile_v2/drivers/newridescreen.dart';
import 'package:last_mile_v2/drivers/regularridescreen.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/main.dart';
import 'package:last_mile_v2/models.dart/ridedetails.dart';
import 'package:last_mile_v2/users/assistants/assistantMethods.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/language_constants.dart';
import '../models.dart/directiondetails.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;
  //final DirectionDetails directionDetails;
  //String distance;

  NotificationDialog({
    this.rideDetails,
    /*this.directionDetails*/
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
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
            SizedBox(height: 30.0),
            Image.asset(
              "images/taxi.png",
              width: 120.0,
            ),
            SizedBox(height: 18.0),
            Text(
              getTranslated(context, "New Ride Request"),
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.0),
            Text(rideDetails.carRideType),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Seats: "),
                Text(
                  rideDetails.carRideType == "regular"
                      ? rideDetails.seatsBooked
                      : "All",
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.pickup_address,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.dropoff_address,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(
                            '',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Divider(
              height: 2.0,
              color: Colors.black,
              thickness: 2.0,
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                      await makeDriverOfflineNow().whenComplete(() async {
                        await _restartApp();

                        //driverStatusHandler.deleteNewRideStatus();
                      });
                    },
                    child: Text(
                      getTranslated(context, "Cancel").toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 25.0),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRide(context);
                      // r = await checkdriverId(context);
                      // if (r == "waiting") {
                      //   checkAvailabilityOfRide(context);
                      // } else {
                      //   displayToastMessage("Ride Missed!", context);
                      //   _restartApp();
                      // }
                    },
                    child: Text(
                      getTranslated(context, "Accept").toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  // String r = "";

  addstatustoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("Online", false);
  }

  DatabaseReference onlineDriverReference = FirebaseDatabase.instance
      .reference()
      .child("availableDrivers")
      .child(FirebaseAuth.instance.currentUser.uid);

  Future<void> makeDriverOfflineNow() async {
    await Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
    await Geofire.stopListener();
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
    onlineDriverReference.onDisconnect();
    onlineDriverReference.remove();
    onlineDriverReference = null;
    addstatustoSF();
  }

  // Future<void> makeDriverOfflineNow() async {
  //   await Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
  //   // rideRequestRef.onDisconnect();
  //   // rideRequestRef.remove();
  //   // rideRequestRef = null;
  //   driverStatusColor = Colors.black;
  //   driverStatusText = "Offline Now - Go Online";
  //   isDriverAvailable = false;
  // }

  // Future<String> checkdriverId(context) async {
  //   String idvalue = "";
  //   await FirebaseDatabase.instance
  //       .reference()
  //       .child("Ride Request")
  //       .child(rideDetails.ride_request_id)
  //       .child("driver_id")
  //       .once()
  //       .then((DataSnapshot snap) {
  //     if (snap.value != null) {
  //       idvalue = snap.value.toString().trim();
  //     }
  //   });
  //   return idvalue;
  // }

  Future<void> _restartApp() async {
    await FlutterRestart.restartApp();
  }

  void checkAvailabilityOfRide(context) async {
    rideRequestRef.once().then((DataSnapshot dataSnapshot) async {
      Navigator.pop(context);

      String theRideId = "";
      // String driverId = "";
      if (dataSnapshot.value != null) {
        theRideId = dataSnapshot.value.toString();
      } else {
        displayToastMessage("Ride Do not Exists", context);
      }

      if (theRideId == rideDetails.ride_request_id) {
        rideRequestRef.set("accepted");

        if (rideDetails.carRideType == "regular") {
          // isRegularRef.set("yes");
          AssistantMethods.disableHomeTabLiveLocationUpdates();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewRegularRideScreen(rideDetails: rideDetails),
            ),
          );
        } else if (rideDetails.carRideType == "reserve" ||
            rideDetails.carRideType == "delivery") {
          // isRegularRef.set("no");
          // makeDriverOfflineNow();
          AssistantMethods.disableHomeTabLiveLocationUpdates();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewRideScreen(rideDetails: rideDetails),
            ),
          );
        }
      } else if (theRideId == "cancelled") {
        displayToastMessage("Ride has been Cancelled", context);
        await makeDriverOfflineNow().whenComplete(() async {
          await _restartApp();
        });
      } else if (theRideId == "timeout") {
        displayToastMessage("Ride has been timedout", context);
        await makeDriverOfflineNow().whenComplete(() async {
          await _restartApp();
        });
      } else {
        displayToastMessage("Ride Do not Exists", context);
        await makeDriverOfflineNow().whenComplete(() async {
          await _restartApp();
        });
      }
    });
  }
}
