import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:last_mile_v2/Notifications/pushnotificationservice.dart';
import 'package:last_mile_v2/drivers/newridescreen.dart';
import 'package:last_mile_v2/drivers/regularridescreen.dart';
import 'package:last_mile_v2/main.dart';
import 'package:last_mile_v2/models.dart/drivers.dart';
import 'package:last_mile_v2/models.dart/ridedetails.dart';
import 'package:last_mile_v2/users/assistants/assistantMethods.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverHomeTabPage extends StatefulWidget {
  @override
  _DriverHomeTabPageState createState() => _DriverHomeTabPageState();
}

class _DriverHomeTabPageState extends State<DriverHomeTabPage>
    with WidgetsBindingObserver {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(25.010812, 88.140899),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  // String driverStatusText = "Offline Now - Go Online";
  // Color driverStatusColor = Colors.black;

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
    WidgetsBinding.instance.addObserver(this);
    if (isDriverAvailable) {
      makeDriverOnlineNow();
    } else {
      makeDriverOfflineNow();
    }
    //wakeLock to keep the screen on
    Wakelock.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) return;

    final isTerminated = state == AppLifecycleState.detached;
    final isForeground = state == AppLifecycleState.resumed;

    if (isTerminated) return;
    if (isForeground) return;

    /* if (isBackground) {
      // service.stop();
    } else {
      // service.start();
    }*/
  }

  fromjson() {
    if (json != null && json != '') {
      makeDriverOfflineNow();
      Map<String, dynamic> map = jsonDecode(json);

      final RideDetails rider = RideDetails.fromJson(map);
      // displayToastMessage("ride details ${rider.carRideType}", context);
      if (rider.carRideType == 'reserve' || rider.carRideType == 'delivery') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewRideScreen(
              rideDetails: rider,
            ),
          ),
        );
      } else if (rider.carRideType == 'regular') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewRegularRideScreen(
              rideDetails: rider,
            ),
          ),
        );
      }
    } else {
      displayToastMessage("No current rides stored", context);
    }
  }

  getRatings() {
    // update Ratings
    firebaseUser = FirebaseAuth.instance.currentUser;
    driversRef
        .child(firebaseUser.uid)
        .child("ratings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        double ratings = double.parse(dataSnapshot.value.toString());
        setState(() {
          driverstarCounter = ratings;
        });
        if (driverstarCounter <= 1) {
          setState(() {
            driverTitle = "Very Bad";
          });
        } else if (driverstarCounter <= 2) {
          setState(() {
            driverTitle = "Bad";
          });
        } else if (driverstarCounter <= 3) {
          setState(() {
            driverTitle = "Good";
          });
        } else if (driverstarCounter <= 4) {
          setState(() {
            driverTitle = "Very Good";
          });
        } else if (driverstarCounter <= 5) {
          setState(() {
            driverTitle = "Excellent";
          });
        }
      }
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    // await AssistantMethods.searchCoordinateAddress(position, context);
    // print("This is your Address: " + address);
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = FirebaseAuth.instance.currentUser;

    driversRef
        .child(currentfirebaseUser.uid)
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    await pushNotificationService.getToken();

    AssistantMethods.retrieveHistoryInfo(context);
    getRatings();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Do you want to exit?"),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("No"),
          ),
          FlatButton(
            onPressed: () {
              Wakelock.disable();
              makeDriverOfflineNow();
              SystemNavigator.pop();
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Stack(
          children: [
            // GoogleMap(
            //   mapType: MapType.normal,
            //   myLocationButtonEnabled: true,
            //   initialCameraPosition: _kGooglePlex,
            //   myLocationEnabled: true,
            //   // zoomGesturesEnabled: true,
            //   // zoomControlsEnabled: true,
            //   onMapCreated: (GoogleMapController controller) {
            //     setState(() {
            //       _controllerGoogleMap.complete(controller);
            //       newGoogleMapController = controller;

            //       locatePosition();
            //     });
            //   },
            // ),
            // Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       // Icon(),
            //       Container(
            //         width: 300.0,
            //         height: 250.0,
            //         decoration: BoxDecoration(
            //           border: Border.all(
            //             width: 1.0,
            //             color: Colors.black,
            //           ),
            //         ),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Text(
            //                 "Available Banners",
            //                 style: TextStyle(
            //                   fontSize: 23,
            //                 ),
            //               ),
            //             ),
            //             SizedBox(
            //               height: 10.0,
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Text("Riqsha Advertisement"),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 16.0),
                //       child: RaisedButton(
                //         onPressed: () async {
                //           if (isDriverAvailable != true) {
                //             await makeDriverOnlineNow();
                //             displayToastMessage(
                //                 "You Are Online Now", context);
                //           } else {
                //             makeDriverOfflineNow();
                //             displayToastMessage(
                //                 "You Are Offline Now", context);
                //           }
                //         },
                //         color: driverStatusColor,
                //         child: Padding(
                //           padding: EdgeInsets.all(17.0),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text(
                //                 driverStatusText,
                //                 style: TextStyle(
                //                   fontSize: 20.0,
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                FlatButton(
                    child: !isDriverAvailable
                        ? Image(
                            image: AssetImage("images/riqsha_black.png"),
                            width: 180.0,
                          )
                        : Image(
                            image: AssetImage("images/riqsha_green.png"),
                            width: 180.0,
                          ),
                    onPressed: () async {
                      if (isDriverAvailable != true) {
                        await makeDriverOnlineNow();
                        displayToastMessage("You Are Online Now", context);
                      } else {
                        makeDriverOfflineNow();
                        displayToastMessage("You Are Offline Now", context);
                      }
                    }),
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      child: Text(
                        "Go to Current Ride",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        fromjson();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;
    Geofire.initialize("availableDrivers");
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser.uid,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    rideRequestRef = FirebaseDatabase.instance
        .reference()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser.uid)
        .child("newRide");

    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) {});

    // Start service to update location in background
    getLocationLiveUpdates();

    setState(() {
      driverStatusColor = Colors.green;
      driverStatusText = "Online Now";
      isDriverAvailable = true;
    });
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (rideRequestRef == null || !isDriverAvailable) {
        homeTabPageStreamSubscription.cancel();
      } else if (isDriverAvailable && rideRequestRef != null) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser.uid,
          position.latitude,
          position.longitude,
        );
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  Future<void> makeDriverOfflineNow() async {
    //Stop service in to update location
    if (isDriverAvailable) {
      homeTabPageStreamSubscription.cancel();
      Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
      rideRequestRef.onDisconnect();
      rideRequestRef.remove();
      rideRequestRef = null;
      setState(() {
        driverStatusColor = Colors.black;
        driverStatusText = "Offline Now - Go Online";
        isDriverAvailable = false;
        // addstatustoSF();
      });
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
