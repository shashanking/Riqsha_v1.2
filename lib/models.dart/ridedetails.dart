import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
  String pickup_address;
  String dropoff_address;
  LatLng pickup;
  LatLng dropoff;
  String ride_request_id;
  String payment_method;
  String rider_name;
  String rider_phone;
  String carRideType;
  String seatsBooked;

  RideDetails({
    this.pickup_address,
    this.dropoff_address,
    this.pickup,
    this.dropoff,
    this.ride_request_id,
    this.payment_method,
    this.rider_name,
    this.rider_phone,
    this.carRideType,
    this.seatsBooked,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickup_address': pickup_address,
      'dropoff_address': dropoff_address,
      'pickup': pickup.toString(),
      'dropoff': dropoff.toString(),
      'ride_request_id': ride_request_id,
      'payment_method': payment_method,
      'rider_name': rider_name,
      'rider_phone': rider_phone,
      'carRideType': carRideType,
      'seatsBooked': seatsBooked,
    };
  }
  
  RideDetails.fromJson(Map<String, dynamic> json) {
    List<String> list1 = json['pickup'].split('(');
    List<String> list2 = list1[1].split(')');
    List<String> pickuplatlong = list2[0].split(',');
    double pickuplat = double.parse(pickuplatlong[0]);
    double pickuplong = double.parse(pickuplatlong[1]);
    List<String> list3 = json['dropoff'].split('(');
    List<String> list4 = list3[1].split(')');
    List<String> dropofflatlong = list4[0].split(',');
    double dropofflat = double.parse(dropofflatlong[0]);
    double dropofflong = double.parse(dropofflatlong[1]); 
    pickup_address = json['pickup_address'];
    dropoff_address = json['dropoff_address'];
    pickup = LatLng(pickuplat, pickuplong);
    dropoff = LatLng(dropofflat, dropofflong);
    ride_request_id = json['ride_request_id'];
    payment_method = json['payment_method'];
    rider_name = json['rider_name'];
    rider_phone = json['rider_phone'];
    carRideType = json['carRideType'];
    seatsBooked = json['seatsBooked'];
  }
}
