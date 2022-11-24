import 'package:flutter/material.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/drivers/driverhistoryscreen.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:provider/provider.dart';

class DriverEarningsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black87,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text(
                  getTranslated(context, "Total Earnings"),
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "₹${Provider.of<AppData>(context, listen: false).earnings}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverHistoryScreen(),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "images/uberx.png",
                      width: 70,
                    ),
                    SizedBox(width: 16),
                    Text(
                      getTranslated(context, "Total Trips"),
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          Provider.of<AppData>(context, listen: false)
                              .countTrips
                              .toString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  getTranslated(context, "Tap for Ride History"),
                  style: TextStyle(fontSize: 11.0),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 2.0,
          thickness: 2.0,
        ),
      ],
    );
  }
}
