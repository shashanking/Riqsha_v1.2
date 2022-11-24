import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String name;
  String email;
  String phone;
  String id;
  String regnumber;
  String regstate;

  Drivers({
    this.name,
    this.phone,
    this.email,
    this.regnumber,
    this.regstate,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot)
  {
    id = dataSnapshot.key;
    phone = dataSnapshot.value["phone"];
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    regnumber = dataSnapshot.value["regnumber"];
    regstate = dataSnapshot.value["regstate"];
  }
}
