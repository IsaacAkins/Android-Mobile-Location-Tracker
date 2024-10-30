import 'dart:async';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tablet_tracker/background.dart'; 
import 'package:tablet_tracker/user_detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_location/fl_location.dart' as fl;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //intialize the connnecton with the firebase
  await Firebase.initializeApp();
  //intializes the connection with hive box
  await Hive.initFlutter();

  await requestPermissions();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox("thebox");
  var mybox = Hive.box("thebox");
  await Permission.location.request();
  if (mybox.get("device") != null) {
    await LaunchApp.openApp(
      androidPackageName: "com.android.settings",
      openStore: true,
    );
    print("the box is full");
    print(mybox.get("device"));
    SystemNavigator.pop();
    FlutterBackgroundService().invoke("setAsForeground");
    FlutterBackgroundService().invoke("setAsBackground");
  } else {
    runApp(const MaterialApp(home: UserDetail()));
  }
}

Future<void> requestPermissions() async {
  await fl.FlLocation.requestLocationPermission();
  final locationPermissionStatus = await Permission.locationAlways.status;
  if (!locationPermissionStatus.isGranted) {
    await Permission.locationAlways.request();
  }

  final notificationPermissionStatus = await Permission.notification.status;
  if (!notificationPermissionStatus.isGranted) {
    await Permission.notification.request();
    
  }

  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
    
  }
  

 if (await Permission.locationAlways.request().isGranted &&
      await Permission.notification.request().isGranted &&
      await Permission.ignoreBatteryOptimizations.request().isGranted) {
    // All necessary permissions are granted
    await initializeService();
      }
}

  