import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/divider.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/main.dart';
import 'package:last_mile_v2/models.dart/directiondetails.dart';
import 'package:last_mile_v2/models.dart/nearbyavailabledrivers.dart';
import 'package:last_mile_v2/users/DriverInfo.dart';
import 'package:last_mile_v2/users/assistants/assistantMethods.dart';
import 'package:last_mile_v2/users/assistants/geofireassistant.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:last_mile_v2/users/schedule_booking.dart';
import 'package:last_mile_v2/users/nodriveravailabledialog.dart';
import 'package:last_mile_v2/users/ratingscreen.dart';
import 'package:last_mile_v2/users/ridercollectfaredialog.dart';
import 'package:last_mile_v2/users/search_location.dart';
import 'package:last_mile_v2/users/searchscreen.dart';
import 'package:last_mile_v2/users/usersdrawer/aboutscreen.dart';
import 'package:last_mile_v2/users/usersdrawer/userdrawerhome.dart';
import 'package:last_mile_v2/users/usersdrawer/userfeedback.dart';
import 'package:last_mile_v2/users/usersdrawer/userrides.dart';
import 'package:last_mile_v2/users/usersdrawer/usersettings.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'assistants/geofireassistant.dart';

class UserMainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";
  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen>
    with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  var geoLocator = Geolocator();
  String scheduleDate;
  String scheduleTime;
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  double optionContainerheight = 0;
  double rideDetailsContainerHeight = 0;

  double searchContainerHeight = 300;
  double requestRideContainerHeight = 0;
  double driverDetailsContainerHeight = 0;
  double nightRate = 0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;
  bool optionToggle = false;

  DatabaseReference rideRequestRef;

  BitmapDescriptor nearbyIcon;

  List<NearbyAvailableDrivers> availableDrivers;

  String state = "normal";

  StreamSubscription<Event> rideStreamSubscription;

  bool isRequestingPositionDetails = false;
  bool scheduleBookingValid = false;

  String uName = "";

  @override
  void initState() {
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
    AssistantMethods.userRetrieveHistoryInfo(context);
    locatePosition();
    AssistantMethods.nightCheck() ? nightRate = 20 : nightRate = 0;
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Request").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideinfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "rider_id": userCurrentInfo.id,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "carRideType": carRideType,
      "seatsBooked": dropdownValue.toString(),
    };

    rideRequestRef.set(rideinfoMap);
    String rideid = rideRequestRef.key;

    rideStreamSubscription = rideRequestRef.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value["car_details"] != null) {
        setState(() {
          carDetailsDriver = event.snapshot.value["car_details"].toString();
          //SetPreferences.setCarDetailsDriver(carDetailsDriver);
        });
      }

      if (event.snapshot.value["driver_name"] != null) {
        setState(() {
          driverName = event.snapshot.value["driver_name"].toString();
          //SetPreferences.setCarDetailsDriver(driverName);
        });
      }
      if (event.snapshot.value["driver_phone"] != null) {
        setState(() {
          driverphone = event.snapshot.value["driver_phone"].toString();
          //SetPreferences.setCarDetailsDriver(driverphone);
        });
      }
      if (event.snapshot.value["driver_location"] != null) {
        double driverLat = double.parse(
            event.snapshot.value["driver_location"]["latitude"].toString());
        double driverLng = double.parse(
            event.snapshot.value["driver_location"]["longitude"].toString());
        LatLng driverCurrentLocation = LatLng(driverLat, driverLng);

        if (statusRide == "accepted") {
          updateRideTimeToPickUpLoc(driverCurrentLocation);
          usersRef
              .child(userCurrentInfo.id)
              .child("history")
              .child(rideid)
              .set(true);
        } else if (statusRide == "onride") {
          updateRideTimeToDropOffLoc(driverCurrentLocation);
        } else if (statusRide == "arrived") {
          setState(() {
            rideStatus = "Driver has Arrived";
            //SetPreferences.setCarDetailsDriver(rideStatus);
          });
        }
      }
      if (event.snapshot.value["status"] != null) {
        statusRide = event.snapshot.value["status"].toString();
      }
      if (statusRide == "accepted") {
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeofireMarker();
      }
      if (statusRide == "ended") {
        if (event.snapshot.value["fares"] != null) {
          int fare = int.parse(event.snapshot.value["fares"].toString());
          DateTime dt = DateTime.now();

          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => RiderCollectFareDialog(
              paymentMethod: "cash",
              fareAmount: fare,
            ),
          );
          String driverId = "";
          if (res == "close") {
            if (event.snapshot.value["driver_id"] != null) {
              driverId = event.snapshot.value["driver_id"].toString();
            }

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RatingScreen(driverId: driverId),
              ),
            );

            rideRequestRef.onDisconnect();
            rideRequestRef = null;
            rideStreamSubscription.cancel();
            rideStreamSubscription = null;
            await resetApp();
            _restartApp();
          }
        }
      }
    });
  }

  void _restartApp() async {
    FlutterRestart.restartApp();
  }

  void deleteGeofireMarker() {
    setState(() {
      markersSet
          .removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }

  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var positionUserLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, positionUserLatLng);
      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = "Driver is Coming - " + details.durationText;
        //SetPreferences.setCarDetailsDriver(rideStatus);
      });

      isRequestingPositionDetails = false;
    }
  }

  void updateRideTimeToDropOffLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var dropOff =
          Provider.of<AppData>(context, listen: false).dropOffLocation;
      var dropOffUserLatLng = LatLng(dropOff.latitude, dropOff.longitude);

      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          driverCurrentLocation, dropOffUserLatLng);
      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = "Going to Destination - " + details.durationText;
      });

      isRequestingPositionDetails = false;
    }
  }

  void cancelRideRequest() {
    //rideRequestRef.remove();

    setState(() {
      state = "normal";
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  void displayDriverDetailsContainer() {
    setState(() {
      requestRideContainerHeight = 0.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 290.0;
      driverDetailsContainerHeight = 310.0;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;

      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();

      statusRide = "";
      driverName = "";
      driverphone = "";
      carDetailsDriver = "";
      rideStatus = "Driver is Coming";
      driverDetailsContainerHeight = 0.0;
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 440;
      bottomPaddingOfMap = 360.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    // print("This is your Address: " + address);

    initGeoFireListener(range: 0.6);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    uName = userCurrentInfo.name;
    print('a');
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(25.010812, 88.140899),
    zoom: 14.4746,
  );

  String profileurl;
  int b;

  var thisfirebaseuser = FirebaseAuth.instance.currentUser;

  String profilepic() {
    usersRef
        .child(thisfirebaseuser.uid)
        .child("imageref")
        .child("url")
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        profileurl = snapshot.value.toString();
      }
    });
    return profileurl;
  }

  int dropdownValue = 1;

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
            onPressed: () => SystemNavigator.pop(),
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    // final appState = Provider.of<AppData>(context);
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          key: scaffoldkey,
          drawer: Container(
            color: Colors.white,
            width: 255.0,
            child: Drawer(
              child: ListView(
                children: [
                  Container(
                    height: 165.0,
                    child: DrawerHeader(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: profilepic() != null
                                    ? Image.network(
                                        profilepic(),
                                        height: 100.0,
                                        width: 100.0,
                                        fit: BoxFit.fill,
                                      )
                                    : CircleAvatar(
                                        child: Image.asset(
                                          "images/user_icon.png",
                                          // height: 70.0,
                                          // width: 80.0,
                                        ),
                                        radius: 50.0,
                                      ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                uName,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  DividerWidget(),
                  SizedBox(height: 12.0),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.home,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "HOME"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserDrawerHome(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.airport_shuttle,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "MY RIDES"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserHistoryScreen(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.assessment,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "FEEDBACK"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserFeedback(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "SETTINGS"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserSettings(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "INFO"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AboutScreen(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 32.0,
                        ),
                        Text(
                          getTranslated(context, "SIGN OUT"),
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ));
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          body: Stack(
                children: [
                  GoogleMap(
                    padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: _kGooglePlex,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    polylines: polylineSet,
                    markers: markersSet,
                    circles: circlesSet,
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _controllerGoogleMap.complete(controller);
                        newGoogleMapController = controller;
                        bottomPaddingOfMap = 300.0;
                        locatePosition();
                      });
                    },
                  ),

                  //hamberger button
                  Positioned(
                    top: 30.0,
                    left: 22.0,
                    child: GestureDetector(
                      onTap: () {
                        if (drawerOpen) {
                          scaffoldkey.currentState.openDrawer();
                        } else {
                          resetApp();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(
                                0.7,
                                0.7,
                              ),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            (drawerOpen) ? Icons.menu : Icons.close,
                            color: Colors.black,
                          ),
                          radius: 20.0,
                        ),
                      ),
                    ),
                  ),

                  // search UI
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: new Duration(milliseconds: 160),
                      child: Container(
                        height: searchContainerHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 16.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 18.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.0),
                              Text(
                                getTranslated(context, "Hi There"),
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                getTranslated(context, "Where to?"),
                                style: TextStyle(fontSize: 24.0),
                              ),
                              SizedBox(height: 20.0),
                              GestureDetector(
                                onTap: () async {
                                  var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchScreen()),
                                  );
                                  if (res == "obtainDirection") {
                                    // await Future.delayed(Duration(seconds: 5)).then((value) => {
                                    // });
                                    displayRideDetailsContainer();
                                  }
                                },
                                child: Container(
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 6.0,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(width: 10.0),
                                      Text(getTranslated(
                                          context, "Search Drop Off")),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.0),
                              GestureDetector(
                                onTap: () async {
                                  var res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchLocation()));
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 12.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Provider.of<AppData>(context)
                                                      .pickUpLocation !=
                                                  null
                                              ? Provider.of<AppData>(context)
                                                  .pickUpLocation
                                                  .placeName
                                              : "Add Home",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          "Tap to change Pickup Location",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Rideing options
                  Positioned(
                    bottom: 40.0,
                    left: 20.0,
                    right: 20.0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: new Duration(milliseconds: 60),
                      child: Container(
                        height: rideDetailsContainerHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 17.0),
                              child: Column(
                                children: [
                                  //bike ride
                                  GestureDetector(
                                    onTap: () {
                                      displayToastMessage(
                                          "Searching Regular", context);
                                      setState(() {
                                        state = "requesting";
                                        carRideType = "regular";
                                      });
                                      // isRegularRef.set("yes");
                                      displayRequestRideContainer();
                                      availableDrivers = GeoFireAssistant
                                          .nearbyAvailableDriversList;
                                      searchNearestDriver();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      // color: Colors.tealAccent[100],
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "images/bike.png",
                                              height: 70.0,
                                              width: 80.0,
                                            ),
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getTranslated(
                                                      context, "Regular"),
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  ((tripDirectionDetails !=
                                                          null)
                                                      ? tripDirectionDetails
                                                          .distanceText
                                                      : ''),
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 26.0,
                                            ),
                                            DropdownButton(
                                              value: dropdownValue,
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text("1"),
                                                  value: 1,
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("2"),
                                                  value: 2,
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("3"),
                                                  value: 3,
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  dropdownValue = value;
                                                  j = value;
                                                });
                                              },
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            Text(
                                              ((tripDirectionDetails != null)
                                                  ? '₹${(AssistantMethods.calculateFares(tripDirectionDetails) * j)}'
                                                  : ''),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Divider(
                                    height: 2.0,
                                    thickness: 2.0,
                                  ),
                                  SizedBox(height: 10.0),

                                  // reserve
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        j = 1;
                                      });
                                      displayToastMessage(
                                          "Searching Reserve", context);
                                      setState(() {
                                        state = "requesting";
                                        carRideType = "reserve";
                                      });
                                      displayRequestRideContainer();
                                      initGeoFireListener(range: 0.8);
                                      Future.delayed(
                                          const Duration(seconds: 10));
                                      availableDrivers = GeoFireAssistant
                                          .nearbyAvailableDriversList;
                                      searchNearestDriver();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      // color: Colors.tealAccent[100],
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "images/ubergo.png",
                                              height: 70.0,
                                              width: 80.0,
                                            ),
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Reserve",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  ((tripDirectionDetails !=
                                                          null)
                                                      ? tripDirectionDetails
                                                          .distanceText
                                                      : ''),
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            Text(
                                              ((tripDirectionDetails != null)
                                                  ? '₹${AssistantMethods.calculateFares(tripDirectionDetails) * 4}'
                                                  : ''),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Divider(
                                    height: 2.0,
                                    thickness: 2.0,
                                  ),
                                  SizedBox(height: 10.0),

                                  // delivery
                                  GestureDetector(
                                    onTap: () {
                                      optionToggle = !optionToggle;
                                      setState(() {
                                        if (optionToggle) {
                                          optionContainerheight = 50.0;
                                        } else {
                                          optionContainerheight = 0.0;
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          // color: Colors.tealAccent[100],
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "images/uberx.png",
                                                  height: 70.0,
                                                  width: 80.0,
                                                ),
                                                SizedBox(
                                                  width: 16.0,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Schedule',
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      ((tripDirectionDetails !=
                                                              null)
                                                          ? tripDirectionDetails
                                                              .distanceText
                                                          : ''),
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(child: Container()),
                                                Column(
                                                  children: [
                                                    Text(
                                                      ((tripDirectionDetails !=
                                                              null)
                                                          ? '₹${AssistantMethods.calculateFares(tripDirectionDetails) * 4 + 10}'
                                                          : ''),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      AssistantMethods
                                                              .nightCheck()
                                                          ? 'Night Charges: + ₹20'
                                                          : '',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          /**Container will hold date and time options */
                                          height: optionContainerheight,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                    child: TextButton(
                                                  onPressed: () {
                                                    var bHour =
                                                        DateTime.now().hour;

                                                    DatePicker
                                                        .showDateTimePicker(
                                                            context,
                                                            showTitleActions:
                                                                true,
                                                            minTime: DateTime
                                                                    .now()
                                                                .add(Duration(
                                                                    hours: 1)),
                                                            maxTime: DateTime
                                                                    .now()
                                                                .add(Duration(
                                                                    days: 7)),
                                                            onConfirm: (data) {
                                                      setState(() {
                                                        scheduleTime =
                                                            "${data.hour}:${data.minute}";
                                                        scheduleDate =
                                                            "${data.year}:${data.month}:${data.day}";
                                                        scheduleBookingValid =
                                                            true;
                                                      });
                                                    });
                                                  },
                                                  child: Text(
                                                    'Select Date And Time',
                                                  ),
                                                )),
                                                Expanded(
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        'Time : $scheduleTime '),
                                                    Text('Date: $scheduleDate')
                                                  ],
                                                )),
                                                FlatButton(
                                                    onPressed: () {
                                                      if (scheduleBookingValid) {
                                                        bookSchedule();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ScheduleBooking()));
                                                      }
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                scheduleBookingValid
                                                                    ? Colors
                                                                        .green
                                                                    : Colors.grey[
                                                                        700],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8),
                                                        child: Text(
                                                          'Book',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )))
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Divider(
                                          height: 2.0,
                                          thickness: 2.0,
                                        ),
                                        scheduleBookingValid
                                            ? Text("")
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                    "Book Schedule atleast an hour early",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 20.0, bottom: 20.0),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.moneyBillAlt,
                                    size: 18.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 16.0),
                                  Text(
                                    getTranslated(context, "Cash"),
                                  ),
                                  SizedBox(width: 6.0),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                    size: 16.0,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Request Cancel UI
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 0.5,
                            blurRadius: 16.0,
                            color: Colors.black54,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      height: requestRideContainerHeight,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            SizedBox(height: 11.0),
                            SizedBox(
                              width: double.infinity,
                              child: ColorizeAnimatedTextKit(
                                text: [
                                  "Requesting a Ride",
                                  "Please Wait",
                                  "Finding a Driver",
                                ],
                                textStyle: TextStyle(
                                    fontSize: 55.0, fontFamily: "Signatra"),
                                colors: [
                                  Colors.green,
                                  Colors.purple,
                                  Colors.pink,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                                ],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () {
                                cancelRideRequest();
                                resetApp();
                              },
                              child: Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26.0),
                                  border: Border.all(
                                      width: 2.0, color: Colors.grey[300]),
                                ),
                                child: Icon(Icons.close, size: 26.0),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              child: Text(
                                getTranslated(context, "Cancel Ride"),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(
                                getTranslated(context,
                                    "Taking too long? Cancel and Search again"),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DriverInfo(driverDetailsContainerHeight, rideStatus,
                      carDetailsDriver, driverName, driverphone),
                ],
              ) ??
              Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void bookSchedule() {
    // 1 create new booking in db
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Schedule Booking").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };
    int sFare;
    AssistantMethods.nightCheck()
        ? sFare = AssistantMethods.calculateFares(tripDirectionDetails) * 4 + 30
        : sFare =
            AssistantMethods.calculateFares(tripDirectionDetails) * 4 + 10;

    Map rideinfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "booking_time": scheduleTime,
      "booking_date": scheduleDate,
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "rider_id": userCurrentInfo.id,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "seatsBooked": 4,
      "fare": sFare,
    };

    rideRequestRef.set(rideinfoMap);
    String rideid = rideRequestRef.key;

    // 2 add booking in user history
    usersRef
        .child(userCurrentInfo.id)
        .child("history")
        .child(rideid)
        .set(false);

    // 3 add a page to check history
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => Center(
    //     child: CircularProgressIndicator(),
    //   ),
    // );

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

    setState(() {
      tripDirectionDetails = details;
    });

    // Navigator.pop(context);

    pr.hide().then((isHidden) {
      // print(isHidden);
    });

    // print("This is Encoded Points ::");
    // print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
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

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
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
      circlesSet.add(pickUpCircle);
      circlesSet.add(dropOffCircle);
    });
  }

  void initGeoFireListener({double range}) {
    Geofire.initialize("availableDrivers");

    // comment nearby drivers
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, range)
        .listen((map) {
      // print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
    // comment
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailablePosition,
        icon: nearbyIcon,
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NoDriverAvailableDialog(),
    );
  }

  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers[0];
    // var k = availableDrivers[0].key;
    // print(k);  print key of driver
    driversRef
        .child(driver.key)
        .child("newRide")
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != "accepted") {
        notifyDriver(driver);
        availableDrivers.removeAt(0);
      } else {
        displayToastMessage("Driver not there", context);
      }
    });
    // notifyDriver(driver);
    // availableDrivers.removeAt(0);
    return;
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    driversRef.child(driver.key).child("newRide").set(rideRequestRef.key);
    driversRef
        .child(driver.key)
        .child("token")
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != null) {
        String token = snap.value.toString();
        AssistantMethods.sendNotificationToDriver(
            token, context, rideRequestRef.key);
      } else {
        return;
      }

      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(driver.key).child("newRide").set("cancelled");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 25;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driversRef.child(driver.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 25;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driversRef.child(driver.key).child("newRide").set("timeout");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 25;
          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
