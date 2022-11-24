import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:last_mile_v2/classes/language.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/main.dart';
import 'package:last_mile_v2/users/configmaps.dart';

import '../driverform.dart';

class DriverProfileTabPage extends StatefulWidget {
  @override
  _DriverProfileTabPageState createState() => _DriverProfileTabPageState();
}

String profileurl;

class _DriverProfileTabPageState extends State<DriverProfileTabPage> {
  @override
  void initState() {
    super.initState();

    //makeDriverOfflineNow();
  }

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  var thisfirebaseuser = FirebaseAuth.instance.currentUser;

  String profilepic() {
    driversRef
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

  // final FirebaseAuth auth = FirebaseAuth.instance;

  // Future signingout() async {
  //   try {
  //     return await auth.signOut();
  //   } catch (e) {
  //     displayToastMessage("SignOut problem ${e.toString()}", context);
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          child: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          radius: 50.0,
                        ),
                ),
                Text(
                  driversInformation.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 65.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // maybe need to change title to drivertitle

                Text(
                  driverTitle + " driver",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blueGrey[200],
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 20.0,
                  width: 200.0,
                  child: Divider(
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 40.0),

                InfoCard(
                  text: driversInformation.phone,
                  icon: Icons.phone,
                ),

                InfoCard(
                  text: driversInformation.email,
                  icon: Icons.email,
                ),

                InfoCard(
                  text: driversInformation.regnumber +
                      " " +
                      driversInformation.regstate,
                  icon: Icons.car_repair,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Language>(
                    dropdownColor: Colors.white,
                    iconSize: 30,
                    hint: Text(
                      getTranslated(context, 'change_language'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (Language language) {
                      _changeLanguage(language);
                    },
                    items: Language.languageList()
                        .map<DropdownMenuItem<Language>>(
                          (e) => DropdownMenuItem<Language>(
                            value: e,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                GestureDetector(
                  onTap: () async {
                    // currentfirebaseUser = FirebaseAuth.instance.currentUser;

                    // await Geofire.removeLocation(currentfirebaseUser.uid);
                    // await makeDriverOfflineNow();
                    // rideRequestRef.onDisconnect();
                    // rideRequestRef.remove();
                    // rideRequestRef = null;
                    // await signingout().whenComplete(() {
                    //   if (FirebaseAuth.instance.currentUser == null) {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (context) => MyHomePage(),
                    //     ));
                    //   } else {
                    //     displayToastMessage("Signout problem", context);
                    //   }
                    // });
                    await FirebaseAuth.instance.signOut().then((_) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          MyHomePage.idScreen, (Route<dynamic> route) => false);
                    });
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MyHomePage(),
                    //   ),
                    // );
                  },
                  child: Card(
                    color: Colors.red,
                    margin: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 110.0,
                    ),
                    child: ListTile(
                      trailing: Icon(
                        Icons.follow_the_signs_outlined,
                        color: Colors.white,
                      ),
                      title: Text(
                        getTranslated(context, "SIGN OUT"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makeDriverOfflineNow() async {
    await Geofire.removeLocation(FirebaseAuth.instance.currentUser.uid);
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

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;

  InfoCard({
    this.text,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 25.0,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
