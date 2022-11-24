import 'package:flutter/material.dart';
import 'configmaps.dart';

class ScheduleBooking extends StatelessWidget {
  ScheduleBooking({Key key}) : super(key: key);
  final String uName = userCurrentInfo.name;

  TextStyle ts = TextStyle(
      fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white);
  TextStyle ts_small = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(50.0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $uName',
                  style: ts,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text('We have recieved your request.', style: ts_small),
                SizedBox(
                  height: 5.0,
                ),
                Text('Confirmation will be sent to your Registered Number',
                    style: ts_small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
