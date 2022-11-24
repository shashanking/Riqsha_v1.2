import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/classes/language.dart';
import 'package:last_mile_v2/drivers/driverlogin.dart';
import 'package:last_mile_v2/drivers/drivermainscreen.dart';
import 'package:last_mile_v2/localization/demo_localization.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/models.dart/ridedetails.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:last_mile_v2/users/userlogin.dart';
import 'package:last_mile_v2/users/usermainscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/wiredash.dart';
import 'classes/language.dart';

bool bres;
SharedPreferences prefs;
RideDetails sfrideDetails;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //@TODO add widgetBinding
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  // await SetPreferences.init();
  bres = await userroute();
  json = prefs.getString('TestRide_Key') ?? '';
  if (json != '' && json != null) {
    sfrideDetails = frommainjson();
  }
  runApp(MyApp());
}

Future<bool> userroute() async {
  if (FirebaseAuth.instance.currentUser == null) {
    return true;
  }
  bool b;
  var sval = "";
  await FirebaseDatabase.instance
      .reference()
      .child("drivers")
      .child(FirebaseAuth.instance.currentUser.uid)
      .child("name")
      .once()
      .then((DataSnapshot snap) {
    if (snap.value != null) {
      sval = snap.value.toString();
      b = false;
    } else {
      b = true;
    }
  });
  // if (sval != null && sval != "") {
  //   b = false;
  // } else if (sval == null) {
  //   b = true;
  // }
  return b;
}

RideDetails frommainjson() {
  RideDetails rider;
  if (json != null && json != '') {
    Map<String, dynamic> map = jsonDecode(json);
    rider = RideDetails.fromJson(map);
    // displayToastMessage("ride details ${rider.carRideType}", context);
    // if (rider.carRideType == "reserve" || rider.carRideType == "delivery") {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => NewRideScreen(
    //         rideDetails: rider,
    //       ),
    //     ),
    //   );
    // } else if (rider.carRideType == "regular") {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => NewRegularRideScreen(
    //         rideDetails: rider,
    //       ),
    //     ),
    //   );
    // }
  } else {
    // displayToastMessage("no json", context);
  }
  return rider;
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: Wiredash(
        secret: secret,
        projectId: projectID,
        navigatorKey: _navigatorKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          title: 'Last Mile App',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          locale: _locale,
          supportedLocales: [
            Locale("en", "US"),
            Locale("hi", "IN"),
            Locale("bn", "IN"),
          ],
          localizationsDelegates: [
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          routes: {
            // UserSignUp.idScreen: (context) => UserSignUp(),
            UserLogin.idScreen: (context) => UserLogin(),
            UserMainScreen.idScreen: (context) => UserMainScreen(),
            MyHomePage.idScreen: (context) => MyHomePage(),
            DriverMainScreen.idScreen: (context) => DriverMainScreen(),
          },
          home: FirebaseAuth.instance.currentUser == null
              ? MyHomePage()
              : bres
                  ? UserMainScreen()
                  : DriverMainScreen(),
        ),
      ),
    );
  }
}

DatabaseReference usersRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("drivers");

//newRide tag
DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child("drivers")
    .child(FirebaseAuth.instance.currentUser.uid)
    .child("newRide");
DatabaseReference newRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Request");

double i = 0;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  static const String idScreen = "homescreen";
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  Widget build(BuildContext context) {
    var _val;
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: RaisedButton(
          color: Colors.green,
          child: Container(
            height: 60.0,
            child: Center(
              child: Text(
                "Continue",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          onPressed: () {
            if (i == 2) {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogin()),
                );
              } else {
                usersRef
                    .child(FirebaseAuth.instance.currentUser.uid)
                    .child("name")
                    .once()
                    .then((DataSnapshot snap) {
                  if (snap.value != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserMainScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserLogin(),
                      ),
                    );
                  }
                });
              }
            }

            if (i == 1) {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverLogin()),
                );
              } else {
                driversRef
                    .child(FirebaseAuth.instance.currentUser.uid)
                    .child("name")
                    .once()
                    .then((DataSnapshot snap) {
                  if (snap.value != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverMainScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverLogin(),
                      ),
                    );
                  }
                });
              }
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'images/logo.png',
                  width: 150,
                ),
                Column(
                  children: [
                    Text(
                      getTranslated(context, "Choose Language"),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 28.0,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Center(
                        child: DropdownButton<Language>(
                          iconSize: 30,
                          hint: Text(
                            getTranslated(context, 'change_language'),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onChanged: (
                            Language language,
                          ) {
                            _changeLanguage(language);
                            _val = language.id;
                          },
                          items: Language.languageList()
                              .map<DropdownMenuItem<Language>>(
                                (e) => DropdownMenuItem<Language>(
                                  value: e,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        e.flag,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      Text(e.name)
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          i = 1;
                        });
                      },
                      child: Container(
                        height: 65,
                        width: 120,
                        child: Center(
                          child: Text(
                            getTranslated(context, "Driver"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: (i == 1) ? Colors.grey : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100.0),
                            bottomLeft: Radius.circular(100.0),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          i = 2;
                        });
                      },
                      child: Container(
                        height: 65,
                        width: 120,
                        child: Center(
                          child: Text(
                            getTranslated(context, "User"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: (i == 2) ? Colors.grey : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100.0),
                            bottomRight: Radius.circular(100.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool getRideRef() {
  bool isDriverSearching;
  rideRequestRef.once().then((value) {
    if (value.toString() == 'searching') {
      isDriverSearching = true;
    } else {
      isDriverSearching = false;
    }
  });
  return isDriverSearching;
}
