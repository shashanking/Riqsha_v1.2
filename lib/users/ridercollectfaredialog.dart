import 'package:flutter/material.dart';
// import 'package:last_mile_v2/users/configmaps.dart';
import 'package:last_mile_v2/localization/language_constants.dart';

class RiderCollectFareDialog extends StatelessWidget {
  final String paymentMethod;
  final int fareAmount;

  RiderCollectFareDialog({this.paymentMethod, this.fareAmount});
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(getTranslated(context, "Trip Fare")),
            SizedBox(height: 22.0),
            Divider(
              height: 2.0,
              thickness: 2.0,
            ),
            SizedBox(height: 16.0),
            Text(
              "₹$fareAmount",
              style: TextStyle(fontSize: 55.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                getTranslated(context,
                    "This is the total trip amount charged to the rider."),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: RaisedButton(
                onPressed: () async {
                  Navigator.pop(context, "close");
                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, "Pay Cash"),
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 26.0,
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
    );
  }
}
