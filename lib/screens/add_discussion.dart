import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/utils/assist.dart';

///Handles profile chanegs by the user
///16 August 2023, Nkole Evans
class AddDiscussionPage extends StatefulWidget {
  const AddDiscussionPage({super.key, required this.title});

  final String title;

  @override
  State<AddDiscussionPage> createState() => _AddDiscussionPageState();
}

class _AddDiscussionPageState extends State<AddDiscussionPage> {
  bool _saving = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descrtiptionController = TextEditingController();

  ///Adds a new discussion to firestore
  void _addDiscussion(String title, String description) async {
    TwysheUser user = await Assist.getUserProfile();

    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreDiscussionsKey)
        .collection(Assist.firestoreDiscussionsKey)
        .add(<String, dynamic>{
      'title': title,
      'description': description,
      'posted': Timestamp.now(),
      'posts': 0,
      'status': 1,
      'user': user.phone,
      'nickname': user.nickname,
      'color': user.color,
      'approver': null,
    }).then((value) {
      setState(() {
        _saving = false;
      });

      Assist.showSnackBar(context,
          'The discussion \'${_titleController.text}\' has been successfully added!');

      ///subscribe to notificatiosn since the user owns it
      Assist.subscribeTopic(value.id);

      Assist.log(
          'The discussion \'${_titleController.text}\' has been successfully added with ref ${value.id}!');

      Navigator.pop(context);
    }).onError((error, stackTrace) {
      setState(() {
        _saving = false;
      });

      Assist.showSnackBar(
          context, 'Unable to add the discussion. Please try again');
      Assist.log('Unable to add the discussion: $error');
    });
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.purple,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  color: Colors.purple[50]),
              child: Column(
                children: [
                  const Image(
                    image: AssetImage('asset/icons/appicon.png'),
                    width: 60,
                  ),
                  const Text(
                      'Please give your discussion a name i.e. \'PrEP Sideffects\' and a short description to tell others what it is about',
                      style: TextStyle(fontSize: 12)),
                  TextFormField(
                    enabled: !_saving,
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    enabled: !_saving,
                    controller: _descrtiptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a short description';
                      }

                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton.icon(
                      icon: !_saving
                          ? const SizedBox()
                          : Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                            40), // fromHeight use double.infinity as width and 40 is the height
                      ),
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.

                          //addMessageToGuestBook(_makeControler.text, _yearController.text);
                          setState(() {
                            _saving = true;
                          });
                          //
                          _addDiscussion(_titleController.text,
                              _descrtiptionController.text);
                        }
                      },
                      label: Text(
                          _saving ? 'POSTING DISCUSSION' : 'POST DISCUSSION'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
