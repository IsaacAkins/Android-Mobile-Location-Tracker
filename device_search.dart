import 'package:admin_version/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeviceSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // Show suggestions again
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('No results found'));
    }
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs;
        var filteredDocs = docs.where((doc) {
          return doc['device']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(filteredDocs[index]['device'].toString()),
              onTap: () {
                close(context, filteredDocs[index]['device']);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs;
        var filteredDocs = docs.where((doc) {
          return doc['device']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return  Center(
            child: Text(
              'No suggestions found',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(filteredDocs[index]['device'].toString()),
              onTap: () {
                query = filteredDocs[index]['device'].toString();
                showResults(context); // Show results on suggestion tap
              },
            );
          },
        );
      },
    );
  }
}
