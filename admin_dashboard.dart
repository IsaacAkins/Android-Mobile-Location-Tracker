import 'package:admin_version/device_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_version/Screen/mymap.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String searchQuery = '';

  void _showSearch() async {
    final String? selected = await showSearch<String>(
      context: context,
      delegate: DeviceSearch(),
    );
    if (selected != null && selected.isNotEmpty) {
      setState(() {
        searchQuery = selected;
      });
    }
  }

  void _goHome() {
    setState(() {
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: searchQuery.isEmpty
            ? const Text('Live Location Tracker')
            : Text('Search result of $searchQuery'),
        actions: [
          IconButton(
            onPressed: _goHome,
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: _showSearch,
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            "List of Registered Devices",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('location').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    return doc['device']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No devices found'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        title: Text(
                          docs[index]['device'].toString(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("Staff Id:"),
                                const SizedBox(width: 20),
                                Text(docs[index]['staff id'].toString()),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Last seen:"),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(docs[index]['time'].toString()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Location Type:"),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(docs[index]['type'].toString()),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MyMap(docs[index].id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
