import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Assist {
  ///The name of the app
  static const appName = 'Twyshe Messenger';

  ///The phone number for a user who is not registered
  static const unregisteredPhone = 'unregistered';

  ///The key used in preferences for a suer
  static const userKey = 'phone';

  ///Checks if the specified phone number is for a registered user
  static bool isRegistered(String phoneNo) {
    if (phoneNo == Assist.unregisteredPhone) {
      return false;
    } else {
      return true;
    }
  }

  ///Adds a message to the debug console
  static void log(String message) {
    if (kDebugMode) {
      print('$appName: $message');
    }
  }

  ///Gets the currently registered user setting on the device
  static Future<String> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentPhone =
        prefs.getString(Assist.userKey) ?? Assist.unregisteredPhone;

    Assist.log(
        'The user currently registered on the device is  \'$currentPhone\'');

    return currentPhone;
  }

  ///Removes the currently registered user setting from the device
  static void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? initialPhone = prefs.getString(Assist.userKey);

    // Save an integer value to 'counter' key.
    await prefs.remove(Assist.userKey);

    String? currentPhone = prefs.getString(Assist.userKey);

    Assist.log(
        'The user has been removed. Initial state was \'$initialPhone\' and is now \'$currentPhone\'');
  }
}
