import 'package:cloud_firestore/cloud_firestore.dart'; // new
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Assist.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _makeController =
      TextEditingController(text: 'Toyota');
  final TextEditingController _yearController =
      TextEditingController(text: '2010');
// Add from here...
  Future<DocumentReference>? addMessageToGuestBook(String make, String year) {
    Future<DocumentReference>? ref;
    try {
      ref = FirebaseFirestore.instance.collection('cars').add(<String, dynamic>{
        'year': year,
        'make': make,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Successfully added car with make $make and year $year")),
      );

      return ref;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to add car: ${e.toString()}")),
      );
    }

    return ref;
  }

  void _setSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save an integer value to 'counter' key.
    await prefs.setString('phone', '260977123456');

    String? phone = prefs.getString('phone');

    Assist.log('The setting phone has been set to $phone');
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  color: Colors.purple[50]),
              child: Column(
                children: [
                  TextFormField(
                    controller: _makeController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the make';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _yearController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a year';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                            40), // fromHeight use double.infinity as width and 40 is the height
                      ),
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.

                          _setSettings();
                          //addMessageToGuestBook(_makeController.text, _yearController.text);
                        }
                      },
                      child: const Text('SUBMIT'),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                            40), // fromHeight use double.infinity as width and 40 is the height
                      ),
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.

                          Assist.removeUser();
                          //addMessageToGuestBook(_makeController.text, _yearController.text);
                        }
                      },
                      child: const Text('REMOVE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
