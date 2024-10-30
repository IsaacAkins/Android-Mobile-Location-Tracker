import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:fl_location/fl_location.dart' as fl;
import 'package:permission_handler/permission_handler.dart';
import 'package:tablet_tracker/landing_page.dart';
import 'package:flutter/services.dart';
class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
   final fl.FlLocation location = fl.FlLocation();
  StreamSubscription<fl.Location>? _locationSubscription;
  final _nameController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _deviceController = TextEditingController();
  final _zoneController = TextEditingController();
  final _branchController = TextEditingController();

  final _mybox = Hive.box("thebox");
  var name;
  var staffId;
  var device;
  var zone;
  var branch;

  @override
  void initState() {
    super.initState();   
    FlutterBackgroundService().invoke("setAsForeground");
    FlutterBackgroundService().invoke("setAsBackground");
  }
  void _register() {
    if (_nameController.text.trim().isEmpty ||
        _staffIdController.text.trim().isEmpty ||
        _deviceController.text.trim().isEmpty ||
        _zoneController.text.trim().isEmpty ||
        _branchController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please enter the correct details'),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text("Close"),
            )
          ],
        ),
      );
      return;
    }

    _submitDetail();
  }

  void _submitDetail()async{
    name = _nameController.text.trim().toUpperCase();
    staffId = _staffIdController.text;
    zone = _zoneController.text.trim().toUpperCase();
    branch = _branchController.text.trim().toUpperCase();
    device = _deviceController.text.trim().toUpperCase();

    _mybox.put("name", name);
    _mybox.put("staff id", staffId);
    _mybox.put("zone", zone);
    _mybox.put("branch", branch);
    _mybox.put("device", device);

    print(_mybox.get("name"));
    print(_mybox.get("zone"));
    
    // FlutterBackgroundService().invoke("setAsForeground");
    // FlutterBackgroundService().invoke("setAsBackground");
    await Permission.locationAlways.request();

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const landingPage()),
    );
  }

  void _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    _zoneController.dispose();
    _branchController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Device Registration",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                maxLength: 50,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  label: const Text("Tablet number"),
                  hintText: "Enter the tablet number",
                ),
                controller: _deviceController,
              ),
              const SizedBox(height: 8),
              TextField(
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  label: const Text("Staff ID"),
                  hintText: "Enter the Staff ID",
                ),
                controller: _staffIdController,
              ),
              const SizedBox(height: 8),
              TextField(
                maxLength: 100,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  label: const Text("Name"),
                  hintText: "Enter the Name",
                ),
                controller: _nameController,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLength: 50,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        label: const Text("Zone"),
                        hintText: "Enter the Zone",
                      ),
                      controller: _zoneController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      maxLength: 50,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        label: const Text("Branch"),
                        hintText: "Enter the Branch",
                      ),
                      controller: _branchController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text("Submit"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
