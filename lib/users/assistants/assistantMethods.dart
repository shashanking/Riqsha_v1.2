import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/models.dart/address.dart';
import 'package:last_mile_v2/models.dart/allUsers.dart';
import 'package:last_mile_v2/models.dart/directiondetails.dart';
import 'package:last_mile_v2/models.dart/history.dart';
import 'package:last_mile_v2/users/assistants/requestAssistant.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:last_mile_v2/main.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][2]["long_name"];
      // st4 = response["results"][0]["address_components"][3]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3;

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionurl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionurl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static bool nightCheck() {
    int hour = DateTime.now().hour;
    if (hour < 21 && hour > 6)
      return false;
    else
      return true;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.10;

    double d = (directionDetails.distanceValue / 1000);

    if (d <= 1.6) {
      distanceTraveledFare = 10;
    } else {
      distanceTraveledFare = (d - 1.6) * 5 + 10;
    }

    double totalFareAmount = distanceTraveledFare;

    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapShot);
      }
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int randNumber = random.nextInt(num);
    return randNumber.toDouble();
  }

  static void disableHomeTabLiveLocationUpdates() {
    firebaseUser = FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(firebaseUser.uid);
  }

  static void enableHomeTabLiveLocationUpdates() {
    firebaseUser = FirebaseAuth.instance.currentUser;
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(
        firebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static sendNotificationToDriver(
      String token, context, String ride_request_id) async {
    var destination =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map notificationMap = {
      'body': 'DropOff Address, ${destination.placeName}',
      'title': 'New Ride Request',
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': ride_request_id,
    };

    Map sendNotificationMap = {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "to": token,
    };

    var res = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headerMap,
      body: jsonEncode(sendNotificationMap),
    );
  }

  static void retrieveHistoryInfo(context) {
    // retrieve and display earnings
    firebaseUser = FirebaseAuth.instance.currentUser;
    driversRef
        .child(firebaseUser.uid)
        .child("earnings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        String earnings = dataSnapshot.value.toString();
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });

    // retrieve and display Trip History
    firebaseUser = FirebaseAuth.instance.currentUser;
    driversRef
        .child(firebaseUser.uid)
        .child("history")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        // update total number of trip count to provider
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false)
            .updateTripsCounter(tripCounter);

        // update trip keys to provider
        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateTripKeys(tripHistoryKeys);
        obtainTriprequestHistoryData(context);
      }
    });
  }

  static void userRetrieveHistoryInfo(context) {
    // retrieve and display Trip History
    firebaseUser = FirebaseAuth.instance.currentUser;
    usersRef
        .child(firebaseUser.uid)
        .child("history")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        // update total number of trip count to provider
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false)
            .updateUserTripsCounter(tripCounter);

        // update trip keys to provider
        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateUserTripKeys(tripHistoryKeys);
        obtainUserTriprequestHistoryData(context);
      }
    });
  }

  static void obtainTriprequestHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      newRequestRef.child(key).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false)
              .updateTripHistoryData(history);
        }
      });
    }
  }

  static void obtainUserTriprequestHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).userTripHistoryKeys;

    for (String key in keys) {
      newRequestRef.child(key).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var history = History.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false)
              .updateUserTripHistoryData(history);
        }
      });
    }
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }
}
