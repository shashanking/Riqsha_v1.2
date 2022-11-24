import 'package:flutter/material.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/drivers/driverhistoryitem.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:provider/provider.dart';

class DriverHistoryScreen extends StatefulWidget {
  @override
  _DriverHistoryScreenState createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, "Trip History")),
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index){
          return DriverHistoryItem(history: Provider.of<AppData>(context, listen: false).tripHistoryDataList[index]);
        },
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 3.0, height: 3.0,),
        itemCount: Provider.of<AppData>(context, listen: false).tripHistoryDataList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
