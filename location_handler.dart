import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // Import the dart:developer library for log statements
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_location/fl_location.dart' as fl;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class LocationListener {
  StreamSubscription<fl.Location>? _locationSubscription;
  Timer? _updateTimer;
  fl.Location? _currentLocation;
  String? type;

  Future<void> listenLocation(Box mybox) async {
    if (_locationSubscription != null) return;

    // Request location permission
    var locationPermissionStatus = await Permission.location.status;
    if (!locationPermissionStatus.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (!await Permission.location.isGranted) {
      log('Location permission not granted');
      return;
    }

    // Use fl_location to listen to location updates
    _locationSubscription = fl.FlLocation.getLocationStream(
      accuracy: fl.LocationAccuracy.high,
    ).listen((fl.Location location) {
      _currentLocation = location;
    }, onError: (dynamic error) {
      log('[onLocation] ERROR: $error');
    });

    _updateTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      var mylocation = loc.Location();
      mylocation.serviceEnabled();
      bool serviceEnabled = await fl.FlLocation.isLocationServicesEnabled;
      if (_currentLocation != null && mybox.get('name') != null && serviceEnabled) {
        type = "GPS";
        _handleLocationUpdate(_currentLocation!, mybox);
      } else {
        log("Location service is not enabled");

        // Fallback to IP-API location
        var ipLocation = await getIpLocation();
        if (ipLocation != null && mybox.get('name') != null) {
          type = "IP";
          _handleLocationUpdate(ipLocation, mybox);
        }
      }
    });
  }

  Future<fl.Location?> getIpLocation() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          log("API connection was successful");
          return fl.Location(
            latitude: data['lat'],
            longitude: data['lon'],
            accuracy: 1000.0, // Default or estimated accuracy
            altitude: 0.0, // IP-based services do not provide altitude
            heading: 0.0, // Not available from IP-based services
            speed: 0.0, // Not available from IP-based services
            speedAccuracy: 0.0, // Not available from IP-based services
            millisecondsSinceEpoch: DateTime.now().millisecondsSinceEpoch.toDouble(),
            timestamp: DateTime.now(),
            isMock: false // Assuming IP-based location is not a mock location
          );
        }
      }
      return null;
    } catch (error) {
      log('Error getting IP location: $error');
      return null;
    }
  }

  Future<void> _handleLocationUpdate(fl.Location location, Box mybox) async {
    final time = DateTime.now();
    final String formattedTime = formatDateTimeToNearestSecond(time);
    if (type == "GPS" ){
      mybox.put('gps_latitude', location.latitude);
      mybox.put('gps_longitude', location.longitude);
      mybox.put('gps_time', formattedTime);
    }

    try {
      await FirebaseFirestore.instance.collection('location').doc(mybox.get('device')).set({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'name': mybox.get('name'),
        'staff id': mybox.get('staff id'),
        'zone': mybox.get('zone'),
        'branch': mybox.get('branch'),
        'device': mybox.get('device'),
        'time': formattedTime,
        'type': type,
        'gps_latitude': mybox.get('gps_latitude') ,
        'gps_longitude': mybox.get('gps_longitude'),
        'gps_time': mybox.get('gps_time'),
      }, SetOptions(merge: true));
      log('Database updated');

      mybox.put("time", time);
      log(mybox.get("time").toString());
      log(mybox.get("device").toString());
    } catch (error) {
      log('Error updating database: $error');
    }
  }

  void stopListening() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  String formatDateTimeToNearestSecond(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }
}
