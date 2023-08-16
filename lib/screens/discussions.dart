import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/screens/add_discussion.dart';
import 'package:kitchen/screens/discussion.dart';

import '../utils/Assist.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DiscussionsPage> createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  // Setting reference to 'tasks' collection
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('twyshe-discussions').snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          body: ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['title']),
                    subtitle: Text('${data['posts'].toString()} Posts'),
                    onTap: () {
                      String make = data['title'] as String;
                      int year = data['posts'] as int;

                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                              content: Text(
                                  "You tapped on car with make $make and year $year")),
                        );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const DiscussionPage(),
                        ),
                      );
                    },
                  );
                })
                .toList()
                .cast(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const AddDiscussionPage(title: 'Add Discussion'),
                ),
              );
            }),
            tooltip: 'Add Discussion',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    ));
  }
}
