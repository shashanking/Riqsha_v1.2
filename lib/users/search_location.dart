import 'package:flutter/material.dart';
import 'package:last_mile_v2/DataHandler/appdata.dart';
import 'package:last_mile_v2/divider.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/models.dart/address.dart';
import 'package:last_mile_v2/models.dart/placepredictions.dart';
import 'package:last_mile_v2/users/assistants/requestAssistant.dart';
import 'package:last_mile_v2/users/configmaps.dart';
import 'package:provider/provider.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key key}) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();

  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";

    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    top: 25.0,
                    right: 25.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 5.0),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back),
                          ),
                          Center(
                            child: Text(
                              "Set Pick Up",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(Icons.add_location),
                          SizedBox(width: 18.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: TextField(
                                  onChanged: (val) => findPlace(val),
                                  controller: pickUpTextEditingController,
                                  decoration: InputDecoration(
                                      hintText: getTranslated(
                                          context, "PickUp Location"),
                                      fillColor: Colors.grey[100],
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                        left: 11.0,
                                        top: 8.0,
                                        bottom: 8.0,
                                      )),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),

              // tile for prediction

              SizedBox(height: 10.0),

              (placePredictionList.length > 0)
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.all(0.0),
                        itemBuilder: (context, index) {
                          return PredictionTile(
                            placePredictions: placePredictionList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            DividerWidget(),
                        itemCount: placePredictionList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&location=25.010812,88.140899&radius=5000&strictbounds";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == "failed") {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10.0),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.0),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    String placeDetailsurl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsurl);

    Navigator.pop(context);

    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(address);
      // print("This is Drop Off Location ::");
      // print(address.longitude);

      Navigator.pop(context, "obtainPickUp");

      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => UserMainScreen(),
      //   ),
      // );
    }
  }
}
