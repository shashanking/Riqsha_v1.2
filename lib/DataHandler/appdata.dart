import 'package:flutter/cupertino.dart';
import 'package:last_mile_v2/models.dart/address.dart';
import 'package:last_mile_v2/models.dart/history.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, dropOffLocation;

  String earnings = "0";
  int countTrips = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];

  int userCountTrips = 0;
  List<String> userTripHistoryKeys = [];
  List<History> userTripHistoryDataList = [];

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateEarnings(String updatedEarnings) {
    earnings = updatedEarnings;
    notifyListeners();
  }

  void updateTripsCounter(int tripCounter) {
    countTrips = tripCounter;
    notifyListeners();
  }

  void updateUserTripsCounter(int tripCounter) {
    userCountTrips = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }
  void updateUserTripKeys(List<String> newKeys) {
    userTripHistoryKeys = newKeys;
    notifyListeners();
  }
  void updateTripHistoryData(History eachHistory) {
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }
  void updateUserTripHistoryData(History eachHistory) {
    userTripHistoryDataList.add(eachHistory);
    notifyListeners();
  }
}
