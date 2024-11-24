import 'package:flutter/material.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/colors.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:twyshe/utils/api.dart';
import 'package:twyshe/utils/assist.dart';

///Handles profile chanegs by the user
///16 August 2023, Nkole Evans
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  String _color = '';

  int _status = Assist.userParticipant;

  String phone = '';

  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _nicknameController = TextEditingController();

  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setUser();
  }

  void _setUser() async {
    TwysheUser profile = await Assist.getUserProfile();

    phone = profile.phone;
    _nicknameController.text = profile.nickname;
    _pinController.text = profile.pin;
    _status = profile.status;
    _emailController.text = profile.email ?? '';

    setState(() {
      _color = profile.color;
    });
  }

  void _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    TwysheTaskResult rs = await TwysheAPI.registerPhone(
        _nicknameController.text,
        phone,
        _pinController.text,
        _color,
        _emailController.text);

    setState(() {
      _isLoading = false;
    });

    if (!rs.succeeded) {
      if (mounted) {
        Assist.showSnackBar(context, rs.message);
      }
    } else {
      //Save the profile settings
      await Assist.saveProfile(_pinController.text, _nicknameController.text,
          _color, _status, _emailController.text);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, 0);
  }

  Future<void> _showChooseColor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ColorPage(
                title: 'Choose Color',
              )),
    );

    if (result != null) {
      setState(() {
        _color = result;
      });
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.purple,
      body: Center(
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
                    const Image(
                      image: AssetImage('asset/icons/appicon.png'),
                      width: 60,
                    ),
                    const Text('${Assist.appName} Settings',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text(
                        'Please choose a simple nickname and enter a PIN to keep your app private',
                        style: TextStyle(fontSize: 12)),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname',
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a nickname';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a PIN to secure your app';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        } else {
                          if (!Assist.isEmailAddressValid(value)) {
                            return 'Please enter a valid email address';
                          }
                        }

                        return null;
                      },
                    ),
                    ListTile(
                      title: const Text('My Color',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          )),
                      subtitle: const Text('Tap to choose a different color',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          )),
                      leading: Icon(
                        Icons.color_lens,
                        color: _color == ''
                            ? Colors.purple
                            : Assist.getHexColor(_color),
                        size: 48,
                      ),
                      onTap: () {
                        _showChooseColor();
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
                            _saveSettings();
                          }
                        },
                        child: _isLoading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: Colors.white),
                              )
                            : const Text('SAVE PROFILE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
