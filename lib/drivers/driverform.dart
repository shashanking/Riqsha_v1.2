import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:last_mile_v2/drivers/drivermainscreen.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/main.dart';

class DriverForm extends StatefulWidget {
  @override
  _DriverFormState createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  File _image, _image1, _image2;
  final picker = ImagePicker();
  TextEditingController firstnameTextEditingController =
      TextEditingController();
  TextEditingController lastnameTextEditingController = TextEditingController();
  TextEditingController dobTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController homeaddressTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  TextEditingController totoTextEditingController = TextEditingController();
  TextEditingController stateTextEditingController = TextEditingController();
  TextEditingController riqshaidTextEditingController = TextEditingController();

  List<String> riqshaidList = [
    "MLDTRIQ001",
    "MLDTRIQ002",
    "MLDTRIQ003",
    "MLDTRIQ004",
    "MLDTRIQ005"
  ];

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromCamera1() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromCamera2() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image2 = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery1() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromGallery2() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image2 = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(getTranslated(context, 'Photo Library')),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(getTranslated(context, 'Camera')),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPicker1(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(getTranslated(context, 'Photo Library')),
                    onTap: () {
                      _imgFromGallery1();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(getTranslated(context, 'Camera')),
                  onTap: () {
                    _imgFromCamera1();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPicker2(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(getTranslated(context, 'Photo Library')),
                    onTap: () {
                      _imgFromGallery2();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(getTranslated(context, 'Camera')),
                  onTap: () {
                    _imgFromCamera2();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool uploading = false;
  DateTime selectedDate = DateTime.now();
  String dateSelected;

  var firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Center(
                        child: _image == null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(120),
                                ),
                                width: 120,
                                height: 120,
                                child: Center(
                                  child: Text(getTranslated(
                                      context, "Enter profile picture")),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: Image.file(
                                  _image,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.fill,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: firstnameTextEditingController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "First Name"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: lastnameTextEditingController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "Last Name"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextFormField(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          final DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(DateTime.now().year - 80),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );

                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                              dobTextEditingController.text =
                                  DateFormat('dd-MM-yyyy').format(selectedDate);
                            });
                          }
                        },

                        controller: dobTextEditingController,

                        // keyboardType: TextInputType.datetime,

                        decoration: InputDecoration(
                          labelText: getTranslated(context, "Date-of-Birth"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),

                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "Phone Number"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "Email Address"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: riqshaidTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText:
                              "Riqsha ID", // needs to change to gettranslated
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 250.0,
                      child: TextField(
                        controller: totoTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "Registered toto number"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: TextField(
                        controller: stateTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "Registered State"),
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 100.0,
                          width: 150.0,
                          child: FlatButton(
                            color: Colors.grey[300],
                            onPressed: () {
                              _showPicker1(context);
                            },
                            child: Center(
                              child: _image1 == null
                                  ? Text(getTranslated(context,
                                      "Upload a Scanned photo of your License"))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.horizontal(),
                                      child: Image.file(
                                        _image1,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          height: 100.0,
                          width: 150.0,
                          child: FlatButton(
                            color: Colors.grey[300],
                            onPressed: () {
                              _showPicker2(context);
                            },
                            child: Center(
                              child: _image2 == null
                                  ? Text(getTranslated(context,
                                      "Upload the number plate of your vehicle"))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.horizontal(),
                                      child: Image.file(
                                        _image2,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    RaisedButton(
                      color: Colors.green,
                      child: Container(
                        height: 60.0,
                        child: Center(
                          child: Text(
                            getTranslated(context, "Continue"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (firstnameTextEditingController.text.length < 2) {
                          displayToastMessage(
                              "First name must be atleast 2 characters",
                              context);
                        } else if (lastnameTextEditingController.text.length <
                            2) {
                          displayToastMessage(
                              "Last name must be atleast 2 characters",
                              context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayToastMessage("Invalid email address", context);
                        } else if (phoneTextEditingController.text.length <
                            10) {
                          displayToastMessage("Invalid Mobile number", context);
                        } else if (totoTextEditingController.text == "") {
                          displayToastMessage(
                              "Invalid Registration number", context);
                        } else {
                          bool flag = false;
                          for (int i = 0; i < riqshaidList.length; i++) {
                            if (riqshaidTextEditingController.text.trim() ==
                                riqshaidList[i]) {
                                  flag = true;
                              String formattedDate =
                                  DateFormat('dd-MM-yyyy – kk:mm')
                                      .format(selectedDate);

                              Map<String, dynamic> userDataMap = {
                                "name": firstnameTextEditingController.text
                                        .trim() +
                                    " " +
                                    lastnameTextEditingController.text.trim(),
                                "email": emailTextEditingController.text.trim(),
                                "phone": phoneTextEditingController.text.trim(),
                                "dob": formattedDate.toString(),
                                "regnumber":
                                    totoTextEditingController.text.trim(),
                                "regstate":
                                    stateTextEditingController.text.trim(),
                                "riqshaId":
                                    riqshaidTextEditingController.text.trim(),
                              };

                              driversRef
                                  .child(firebaseUser.uid)
                                  .set(userDataMap);

                              FirebaseFirestore.instance
                                  .collection('drivers')
                                  .doc(firebaseUser.uid)
                                  .set(userDataMap);

                              setState(() {
                                uploading = true;
                              });

                              uploadAllImage(context).whenComplete(
                                () => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverMainScreen(),
                                    ),
                                    (route) => false),
                              );

                              displayToastMessage(
                                  "Congrats, your account has been created",
                                  context);
                            }
                          }
                          if(flag==false)
                          {
                            displayToastMessage(
                                  "Enter Correct Riqsha ID",
                                  context);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            uploading
                ? Center(
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            child: Text(
                              'uploading...',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CircularProgressIndicator()
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  CollectionReference imgRef;

  Future uploadAllImage(BuildContext context) async {
    await uploadImageToFirebase(context);
    await uploadImageToFirebase1(context);
    await uploadImageToFirebase2(context);
  }

  Future uploadImageToFirebase(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String filePath = 'drivers/${DateTime.now()}.png';
    Reference ref = storage.ref().child(filePath);
    // UploadTask uploadTask = ref.putFile(_image);
    // uploadTask.then((res) {
    //   res.ref.getDownloadURL().then((value) {
    //     imgRef.add({'url': value});
    //     val++;
    //   });
    // });
    await ref.putFile(_image).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        imgRef.doc(firebaseUser.uid).collection('imageref').add({'url': value});
        driversRef.child(firebaseUser.uid).child("imageref")
            // .child("url")
            .set({"url": value});
      });
    });
  }

  Future uploadImageToFirebase1(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String filePath = 'drivers/${DateTime.now()}.png';
    Reference ref = storage.ref().child(filePath);
    // UploadTask uploadTask = ref.putFile(_image);
    // uploadTask.then((res) {
    //   res.ref.getDownloadURL().then((value) {
    //     imgRef.add({'url': value});
    //     val++;
    //   });
    // });
    await ref.putFile(_image1).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        imgRef
            .doc(firebaseUser.uid)
            .collection('imageref')
            .add({'url1': value});
        // driversRef
        //     .child(firebaseUser.uid)
        //     .child("imageref")
        //     .set({"url1": value});
      });
    });
  }

  Future uploadImageToFirebase2(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String filePath = 'drivers/${DateTime.now()}.png';
    Reference ref = storage.ref().child(filePath);
    // UploadTask uploadTask = ref.putFile(_image);
    // uploadTask.then((res) {
    //   res.ref.getDownloadURL().then((value) {
    //     imgRef.add({'url': value});
    //     val++;
    //   });
    // });
    await ref.putFile(_image2).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        imgRef
            .doc(firebaseUser.uid)
            .collection('imageref')
            .add({'url2': value});
        // driversRef
        //     .child(firebaseUser.uid)
        //     .child("imageref")
        //     .set({"url2": value});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('drivers');
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
