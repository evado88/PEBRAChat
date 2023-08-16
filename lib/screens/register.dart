import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/screens/home.dart';
import 'package:kitchen/screens/profile.dart';

import '../utils/Assist.dart';

///Handles user registration
///16 August 2023, Nkole Evans
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String countryPrefix = '+260';
  int stage = 1;
  bool _registrationComplete = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController =
      TextEditingController(text: '977123451');

  final TextEditingController _codeController =
      TextEditingController(text: '123456');

  String _verificationId = '';

  ///Gets the full number based on the selected country and entered phone number
  String _getFullNumber() {
    return '$countryPrefix${_phoneController.text}';
  }

  void saveProfie() {
    //Do not include the + in the number when saving
    Assist.registerUser(_getFullNumber().substring(1));

    //show home page
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HomePage(title: Assist.appName),
        ),
      );
    }
  }

  Future<void> _showSaveProfille() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ProfilePage(
                title: 'Update Profile',
              )),
    );

    if (!mounted) return;

    if (result == null || result != 0) {
      Assist.showSnackBar(
          context, "Please set your nickname and PIN to proceed");
    } else {
      saveProfie();
    }
  }

  ///Verifies the code the user has entered
  void verifyCode() async {
    String smsCode = _codeController.text;

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: smsCode);

      await FirebaseAuth.instance.signInWithCredential(credential);
      Assist.log(
          'The user has successfully logged in with phone \'${_getFullNumber()}\'');

      setState(() {
        _registrationComplete = true;
      });

      _showSaveProfille();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Assist.log('The provided code \'$smsCode\' is not valid.');

        Assist.showSnackBar(
            context, 'The provided code \'$smsCode\' is not valid.');
      } else {
        Assist.log('Unable to verify phone numeber: \'${e.code}\'');

        Assist.showSnackBar(
            context, 'Unable to verify phone numeber: \'${e.code}\'');
      }
    }
  }

  ///Starts the phone number sign in process
  void signIn() async {
    Assist.log(
        'Starting phone number auth for phone number ${_getFullNumber()}');

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _getFullNumber(),
      verificationCompleted: (PhoneAuthCredential credential) {
        // ANDROID ONLY!
        Assist.log('The user has signed in automatically on android');

        setState(() {
          _registrationComplete = true;
        });

        _showSaveProfille();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Assist.log('The provided phone number is not valid.');

          Assist.showSnackBar(
              context, 'The provided phone number is not valid.');
        }
        Assist.log(e.message ?? 'unknown eror');
        // Handle other errors
      },
      codeSent: (String verificationId, int? resendToken) async {
        Assist.log('The code been sent to the user');
        // Update the UI - wait for the user to enter the SMS code
        //switch to otp entry
        _verificationId = verificationId;
        setState(() {
          stage = 2;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  ///Gets the view based on the current state
  Widget _getStageView() {
    if (stage == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.white),
                    color: Colors.purple[50]),
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage('asset/icons/appicon.png'),
                      width: 120,
                    ),
                    const Text(Assist.appName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text(
                        'To start, please enter your mobile phone number',
                        style: TextStyle(fontSize: 12)),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Zambia'),
                      onPressed: () => Assist.log('Country pressed'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: countryPrefix,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please a valid phone number';
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

                            //addMessageToGuestBook(_makeController.text, _yearController.text);
                            signIn();
                          }
                        },
                        child: const Text('PROCEED'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.white),
                    color: Colors.purple[50]),
                child: Column(
                  children: [
                    const Text(Assist.appName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        _registrationComplete
                            ? 'Please set your nickname and PIN to proceed'
                            : 'Please enter the code that has been sent to the phone number ${_getFullNumber()}',
                        style: const TextStyle(fontSize: 12)),
                    _registrationComplete
                        ? const SizedBox()
                        : TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Change Phone Number'),
                            onPressed: () {
                              setState(() {
                                stage = 1;
                              });
                            },
                          ),
                    _registrationComplete
                        ? const SizedBox()
                        : TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid code';
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

                            //addMessageToGuestBook(_makeController.text, _yearController.text);
                            if (_registrationComplete) {
                              Assist.log(
                                  'Registration is complete. Awaiting profile...');
                              _showSaveProfille();
                            } else {
                              verifyCode();
                            }
                          }
                        },
                        child:
                            Text(_registrationComplete ? 'FINISH' : 'VERIFY'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
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
      body: _getStageView(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
