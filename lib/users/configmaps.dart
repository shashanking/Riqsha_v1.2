import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:last_mile_v2/models.dart/allUsers.dart';
import 'package:last_mile_v2/models.dart/drivers.dart';

String mapKey = "AIzaSyB4L29EIwu2DAKKo34OF6xoHCuOkAXkj1E";

User firebaseUser;

Users userCurrentInfo;

User currentfirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;

StreamSubscription<Position> rideStreamSubscription;

String driverStatusText = "Offline Now - Go Online";
Color driverStatusColor = Colors.black;


final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

Drivers driversInformation;

int driverRequestTimeOut = 25;

String json = '';

String statusRide = "";
String rideStatus = "Driver is Coming";
String carDetailsDriver = "";
String driverName = "";
String driverphone = "";
String carRideType = "";

double starCounter = 0.0;
String title = "";
String driverTitle = "";

double driverstarCounter = 0.0;

bool isDriverAvailable = false;

String serverToken = "key=AAAADQc20Yg:APA91bFa5xSVcihMlmC7jTqvrS_56zuwymWOtqAcVFrhAoXf_mnyMi5NSRzeeKFgnjmfOYk8DpEys3JZ_lkvCkGBcABonKZM4pBcEUk9oz5J4gbkUNz_vraB7rRu4BMg0sDcDSn-Buxz";

String secret = "rybz4ucoha57ux8be1ojs2lqctks704ij2lkfoglcr7agu6v";
String projectID = "riqsha-jd1q13l";

int j=1;