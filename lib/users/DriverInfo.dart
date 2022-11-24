import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfo extends StatelessWidget {
  const DriverInfo(this.driverDetailsContainerHeight, this.rideStatus,
      this.carDetailsDriver, this.driverName, this.driverphone);

  final double driverDetailsContainerHeight;
  final String rideStatus;
  final String carDetailsDriver;
  final String driverName;
  final String driverphone;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
        height: driverDetailsContainerHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rideStatus,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.0),
              Divider(
                height: 2.0,
                thickness: 2.0,
              ),
              SizedBox(height: 22.0),
              Text(
                carDetailsDriver,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                driverName,
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 22.0),
              Divider(
                height: 2.0,
                thickness: 2.0,
              ),
              SizedBox(height: 22.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // call Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: RaisedButton(
                      onPressed: () async {
                        launch('tel://$driverphone');
                      },
                      color: Colors.pink,
                      child: Padding(
                        padding: EdgeInsets.all(17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              getTranslated(context, "Call Driver"),
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                            Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 26.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Cancel button
                  // RaisedButton(
                  //   child: Text(
                  //     "End Trip",
                  //     style: TextStyle(fontSize: 15.0),
                  //   ),
                  //   onPressed: () async {

                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
