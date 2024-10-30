import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserInfo extends StatefulWidget {
  final String userId;
  UserInfo(this.userId, {super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  DocumentSnapshot<Map<String, dynamic>>? userInfo;
  var latitude;
  var longitude;

  void _loadData() async {
    userInfo = await FirebaseFirestore.instance
        .collection('location')
        .doc(widget.userId)
        .get();
    latitude = userInfo!.data()!["latitude"];
    longitude = userInfo!.data()!["longitude"];
    setState(() {}); // Call setState to update the UI after data is loaded
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Details"),
      ),
      body: userInfo == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator while data is loading
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Staff Name: ${userInfo!.data()!["name"]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Staff ID: ${userInfo!.data()!["staff id"]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Branch : ${userInfo!.data()!["branch"]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Zone: ${userInfo!.data()!["zone"]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Device Number: ${userInfo!.data()!['device']}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Time: ${userInfo!.data()!['time']}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
