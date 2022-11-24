import 'package:flutter/material.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/drivers/driverhistoryitem.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:provider/provider.dart';

class UserHistoryScreen extends StatefulWidget {
  @override
  _UserHistoryScreenState createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(getTranslated(context, "Ride History")),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return DriverHistoryItem(
              history: Provider.of<AppData>(context, listen: false)
                  .userTripHistoryDataList[index]);
        },
        separatorBuilder: (BuildContext context, int index) => Divider(
          thickness: 3.0,
          height: 3.0,
        ),
        itemCount: Provider.of<AppData>(context, listen: false)
            .userTripHistoryDataList
            .length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
