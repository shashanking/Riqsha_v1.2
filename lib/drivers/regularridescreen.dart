import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:last_mile_v2/drivers/collectfaredialog.dart';
import 'package:last_mile_v2/drivers/driverform.dart';
import 'package:last_mile_v2/main.dart';
import 'package:last_mile_v2/models.dart/ridedetails.dart';
import 'package:last_mile_v2/users/assistants/assistantMethods.dart';
import 'package:last_mile_v2/users/assistants/mapkitassistant.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

class NewRegularRideScreen extends StatefulWidget {
  final RideDetails rideDetails;
  NewRegularRideScreen({this.rideDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  _NewRegularRideScreenState createState() => _NewRegularRideScreenState();
}

class _NewRegularRideScreenState extends State<NewRegularRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newRideGoogleMapController;
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCoOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFrombottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor animatingMarkerIcon;
  Position myPosition;
  String status = "accepted";
  String durationRide = "";
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  Timer timer;
  int durationCounter = 0;

  // Future<void> makeDriverOfflineNow() async {
  //   await Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
  //   // rideRequestRef.onDisconnect();
  //   // rideRequestRef.remove();
  //   // rideRequestRef = null;
  // }

  Future<void> makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
    driverStatusColor = Colors.green;
    driverStatusText = "Online Now";
    isDriverAvailable = true;
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    acceptRideRequest();
    loadData();
    saveData();
  }

  loadData() async {
    // prefs = await SharedPreferences.getInstance();

    setState(() {
      json = prefs.getString('TestRide_Key') ?? '';
    });
  }

  saveData() async {
    // prefs = await SharedPreferences.getInstance();
    final testRide = RideDetails(
      pickup_address: widget.rideDetails.pickup_address,
      dropoff_address: widget.rideDetails.dropoff_address,
      pickup: widget.rideDetails.pickup,
      dropoff: widget.rideDetails.dropoff,
      ride_request_id: widget.rideDetails.ride_request_id,
      payment_method: widget.rideDetails.payment_method,
      rider_name: widget.rideDetails.rider_name,
      rider_phone: widget.rideDetails.rider_phone,
      carRideType: widget.rideDetails.carRideType,
      seatsBooked: widget.rideDetails.seatsBooked,
    );

    setState(() {
      json = jsonEncode(testRide.toJson());
    });
    // displayToastMessage("the json data is $json", context);

    prefs.setString('TestRide_Key', json);
  }

  clearData() async {
    // prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/car_android.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, myPosition.latitude, myPosition.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPosition,
        icon: animatingMarkerIcon,
        rotation: rot,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((marker) => marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
      oldPos = mPosition;
      updateRideDetails();

      String rideRequestId = widget.rideDetails.ride_request_id;

      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
      };

      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  Future<void> _restartApp() async {
    FlutterRestart.restartApp();
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
    createIconMarker();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapPaddingFrombottom),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: NewRegularRideScreen._kGooglePlex,
              myLocationEnabled: true,
              markers: markersSet,
              circles: circleSet,
              polylines: polyLineSet,
              // zoomGesturesEnabled: true,
              // zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                _controllerGoogleMap.complete(controller);
                newRideGoogleMapController = controller;

                setState(() {
                  mapPaddingFrombottom = 265.0;
                });

                var currentLatLng =
                    LatLng(currentPosition.latitude, currentPosition.longitude);
                var pickUpLatLng = widget.rideDetails.pickup;

                await getPlaceDirection(currentLatLng, pickUpLatLng);

                getRideLiveLocationUpdates();
              },
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: 270.0,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    children: [
                      Text(
                        durationRide,
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.rideDetails.rider_name,
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: IconButton(
                              onPressed: () async {
                                launch(
                                    'tel://${widget.rideDetails.rider_phone}');
                              },
                              color: Colors.pink,
                              icon: Icon(Icons.call),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Image.asset(
                            "images/pickicon.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                          SizedBox(width: 18.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.rideDetails.pickup_address,
                                style: TextStyle(fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Image.asset(
                            "images/desticon.png",
                            height: 16.0,
                            width: 16.0,
                          ),
                          SizedBox(width: 18.0),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.rideDetails.dropoff_address,
                                style: TextStyle(fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 26.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: RaisedButton(
                          onPressed: () async {
                            if (status == "accepted") {
                              status = "arrived";
                              String rideRequestId =
                                  widget.rideDetails.ride_request_id;
                              newRequestRef
                                  .child(rideRequestId)
                                  .child("status")
                                  .set(status);

                              setState(() {
                                btnTitle = "Start Trip";
                                btnColor = Colors.purple;
                              });

                              final ProgressDialog pr = ProgressDialog(context,
                                  type: ProgressDialogType.Normal);

                              pr.style(
                                message: 'Please Wait...',
                                borderRadius: 10.0,
                                backgroundColor: Colors.white,
                                progressWidget: CircularProgressIndicator(),
                                elevation: 10.0,
                                insetAnimCurve: Curves.easeInOut,
                                progress: 0.0,
                                maxProgress: 100.0,
                                progressTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                messageTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              );

                              await pr.show();

                              await getPlaceDirection(widget.rideDetails.pickup,
                                  widget.rideDetails.dropoff);

                              // await makeDriverOnlineNow();

                              pr.hide().then((isHidden) {
                                // print(isHidden);
                              });
                              // makeDriverOfflineNow();

                            } else if (status == "arrived") {
                              status = "onride";
                              String rideRequestId =
                                  widget.rideDetails.ride_request_id;
                              newRequestRef
                                  .child(rideRequestId)
                                  .child("status")
                                  .set(status);

                              setState(() {
                                btnTitle = "End Trip";
                                btnColor = Colors.redAccent;
                              });

                              initTimer();
                            } else if (status == "onride") {
                              clearData();
                              endTheTrip();
                            }
                          },
                          color: btnColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  btnTitle,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.directions_car,
                                  color: Colors.white,
                                  size: 26.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    final ProgressDialog pr =
        ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
      message: 'Getting Location...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
        fontWeight: FontWeight.w600,
      ),
    );

    await pr.show();

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    pr.hide().then((isHidden) {
      // print(isHidden);
    });

    // print("This is Encoded Points ::");
    // print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    polylineCoOrdinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCoOrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylineCoOrdinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpCircle = Circle(
      fillColor: Colors.yellow,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellow,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circleSet.add(pickUpCircle);
      circleSet.add(dropOffCircle);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        '${driversInformation.regnumber} - ${driversInformation.regstate}');

    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString(),
    };

    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);

    driversRef
        .child(currentfirebaseUser.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
    // makeDriverOfflineNow();
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      if (myPosition == null) {
        return;
      }
      var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickup;
      } else {
        destinationLatLng = widget.rideDetails.dropoff;
      }

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng);

      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }

      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async {
    timer.cancel();

    final ProgressDialog pr =
        ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
      message: 'Please Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
        fontWeight: FontWeight.w600,
      ),
    );

    await pr.show();

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(
        widget.rideDetails.pickup, currentLatLng);

    pr.hide().then((isHidden) {
      // print(isHidden);
    });

    int sb = int.parse(widget.rideDetails.seatsBooked);
    assert(sb is int);

    int fareAmount = AssistantMethods.calculateFares(directionalDetails) * sb;

    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef
        .child(rideRequestId)
        .child("fares")
        .set(fareAmount.toString());

    //driverStatusHandler.deleteNewRideStatus();
    newRequestRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectFareDialog(
          paymentMethod: widget.rideDetails.payment_method,
          fareAmount: fareAmount),
    ).whenComplete(() async {
      await saveEarnings(fareAmount);
    });
  }

  Future<void> saveEarnings(int fareAmount) async {
    currentfirebaseUser = FirebaseAuth.instance.currentUser;
    driversRef
        .child(currentfirebaseUser.uid)
        .child("earnings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        double oldEarnings = double.parse(dataSnapshot.value.toString());
        double totalEarnings = fareAmount + oldEarnings;

        driversRef
            .child(currentfirebaseUser.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();

        driversRef
            .child(currentfirebaseUser.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      }
    }).whenComplete(() async {
      await makeDriverOfflineNow().whenComplete(() async {
        await _restartApp();
      });
    });
  }

  // addstatustoSF() async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs.setBool("Online", false);
  // }

  Future<void> makeDriverOfflineNow() async {
    await Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
    await Geofire.stopListener();
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
    // addstatustoSF();
  }
}
