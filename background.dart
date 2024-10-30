import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tablet_tracker/location_handler.dart';
import "package:workmanager/workmanager.dart";

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      initialNotificationContent: "Searching for Updates",
      initialNotificationTitle: "App Update",
    ),
    iosConfiguration: IosConfiguration(),
  );
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false
  );
  await Workmanager().registerPeriodicTask(
    "",
    "",
    frequency: const Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );

}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "":
        await Firebase.initializeApp();
        await Hive.initFlutter();
        final mybox = await Hive.openBox("thebox");
        final locationListener = LocationListener();
        await locationListener.listenLocation(mybox);
        break;
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox("thebox");
 
  FlutterScreenWake.keepOn(true);
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    service.stopSelf();
  });
  
  final mybox = Hive.box("thebox");
  final locationListener = LocationListener();
  locationListener.listenLocation(mybox); 
}

