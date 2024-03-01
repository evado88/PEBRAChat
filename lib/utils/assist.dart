import 'dart:math';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/classes/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

///Contains common properties and methods for the entire application
///Date: 16 August 2023
///Author: Nkole Evans
class Assist {
  ///The name of the app
  static const appName = 'Twyshe Messenger';

  ///The code of the app
  static const appCode = 'Twyshe';

  ///The active api URL of the app
  static const apiUrl = 'http://nkoleevans.pythonanywhere.com';

  //The local URL for the api
  static const localApiUrl = 'http://10.0.2.2:5000';

  //The online  URL for the api
  static const onlineApiUrl = 'http://nkoleevans.pythonanywhere.com';

  ///The phone number for a user who is not registered
  static const unregisteredPhone = 'unregistered';

  ///The fcm token for a device that doesnt have one
  static const unregisteredToken = 'fcmToken';

  ///The key used in preferences for a user
  static const userKey = 'phone';

  ///The key used in preferences for a pin
  static const pinKey = 'pin';

  ///The key used in preferences for a nickname
  static const nicknameKey = 'nickname';

  ///The key used in preferences for a color
  static const colorKey = 'color';

  ///The key used in preferences for a peer navigators nickname
  static const pnnicknamekey = 'pnnickname';

  ///The key used in preferences for a peer navigators phone
  static const pnuserKey = 'pnphone';

  ///The key used in firestore to store data for the app
  static const firestoreAppCode = 'twyshe';

  ///The key used in firestore to store discussions
  static const firestoreDiscussionsKey = 'twyshe-discussions';

  ///The key used in firestore to store posts for a  discussion
  static const firestoreDiscussionPostsKey = 'twyshe-discussion-posts';

  ///The key used in firestore to store conversations
  static const firestoreConversationsKey = 'twyshe-conversations';

  ///The key used in firestore to store the chats for a conversation
  static const firestoreConversationChatsKey = 'twyshe-chats';

  ///The status of the message which is active
  static const messageStateActive = 1;

  ///The status of the message which is deleted
  static const messageStateDeleted = 2;

  ///The key for the FCM token
  static const String fcmTokenKey = 'fcmtoken';

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

  ///Gest the ID of the conversation based on the phone number
  static String? getCoversationId(String phone1, String phone2) {
    String? conversationId;

    int rs = phone1.compareTo(phone2);

    if (rs == 0) {
      conversationId = null;
    } else if (rs == -1) {
      conversationId = '${phone1}_${phone2}';
    } else {
      conversationId = '${phone2}_${phone1}';
    }

    return conversationId;
  }

  ///Gets the currently registered user setting on the device
  static Future<String> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentPhone =
        prefs.getString(Assist.userKey) ?? Assist.unregisteredPhone;

    Assist.log(
        'The user currently registered on the device is \'$currentPhone\'');

    return currentPhone;
  }

  ///Gets the currently registered user setting on the device
  static Future<TwysheUser> getUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentPhone =
        prefs.getString(Assist.userKey) ?? Assist.unregisteredPhone;
    String currentPin = prefs.getString(Assist.pinKey) ?? '';
    String currentNickname = prefs.getString(Assist.nicknameKey) ?? '';
    String currentColor = prefs.getString(Assist.colorKey) ?? '';
    String? currentPnPhone = prefs.getString(Assist.pnuserKey) ?? '';

    TwysheUser user = TwysheUser(currentPhone, currentNickname, currentColor,
        currentPin, currentPnPhone);

    return user;
  }

  ///Registers the specified user on the device
  static void registerUser(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? initialPhone = prefs.getString(Assist.userKey);

    // Save an integer value to 'counter' key.
    await prefs.setString(Assist.userKey, phone);

    String? currentPhone = prefs.getString(Assist.userKey);

    Assist.log(
        'The user has been registered on the device. Initial state was \'$initialPhone\' and is now \'$currentPhone\'');
  }

  ///Saves the FCM token on the device
  static void saveFCMToken(String? token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? initialToken = prefs.getString(Assist.fcmTokenKey);

    // Save an integer value to 'counter' key.
    await prefs.setString(
        Assist.fcmTokenKey, token ?? Assist.unregisteredToken);

    String? currentToken = prefs.getString(Assist.fcmTokenKey);

    Assist.log(
        'The token has been saved on the device. Initial state was \'$initialToken\' and is now \'$currentToken\'');
  }

  ///Gets the currently saved FCM token on the device
  static Future<String> getFCMToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentToken =
        prefs.getString(Assist.fcmTokenKey) ?? Assist.unregisteredToken;

    Assist.log('The currently saved token on the device is \'$currentToken\'');

    return currentToken;
  }

  ///Registers the specified user on the device
  static Future<bool> saveProfile(
      String pin, String nickname, String color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? initialPin = prefs.getString(Assist.pinKey);
    String? initialNickname = prefs.getString(Assist.nicknameKey);
    String? initialColor = prefs.getString(Assist.colorKey);

    String? initialPnPhone = prefs.getString(Assist.pnuserKey);
    String? initialPnNickname = prefs.getString(Assist.pnnicknamekey);

    await prefs.setString(Assist.pinKey, pin);
    await prefs.setString(Assist.nicknameKey, nickname);
    await prefs.setString(Assist.colorKey, color);

    int rnd = Random().nextInt(7);


    String pnPhone = '26097712300${rnd + 1}';

    await prefs.setString(Assist.pnnicknamekey, 'mypn');
    await prefs.setString(Assist.pnuserKey, pnPhone);

    String? currentPin = prefs.getString(Assist.pinKey);
    String? currentNickname = prefs.getString(Assist.nicknameKey);
    String? currentColor = prefs.getString(Assist.colorKey);

    String? currentPnPhone = prefs.getString(Assist.pnuserKey);
    String? currentPnNickname = prefs.getString(Assist.pnnicknamekey);

    String initials =
        'Nickname: $initialNickname, Color: $initialColor, PIN: $initialPin, PN-Nickname: $initialPnNickname, PN-Phone: $initialPnPhone';

    String currents =
        'Nickname: $currentNickname, Color: $currentColor, PIN: $currentPin, PN-Nickname: $currentPnNickname, PN-Phone: $currentPnPhone';

    Assist.log(
        'The profile has been updated. Initial values; $initials, Currents: $currents');

    return true;
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

  ///Shows a snackbar and removes any current ones
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  ///Gets the hex code for the color
  static String getColorHex(Color color) {
    var hex = '#${color.value.toRadixString(16).padLeft(6, '0')}';
    return hex;
  }

  ///Gets the code for the hex code
  static Color getHexColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xff')));
  }

  ///Subscribes to the specified topic
  static void subscribeTopic(String topic) {
    Assist.log('Subscribing to the topic $topic');

    FirebaseMessaging.instance
        .subscribeToTopic(topic)
        .then((value) =>
            Assist.log('Successfully subscribed to the topic $topic'))
        .onError((error, stackTrace) =>
            Assist.log('Unable to subscribe to the topic $topic: $error'));
  }

  ///Unsubscribes to the specified topic
  static void unsubscribeTopic(String topic) {
    Assist.log('Unsubscribing from the topic $topic');

    FirebaseMessaging.instance
        .unsubscribeFromTopic(topic)
        .then((value) =>
            Assist.log('Successfully unsubscribed to the topic $topic'))
        .onError((error, stackTrace) =>
            Assist.log('Unable to unsubscribe to the topic $topic: $error'));
  }

  ///Opens the specified link as a web link
  static void openWebLink(BuildContext context, String link) async {
    Assist.log('Starting to open the provided web link: $link');

    final Uri url = Uri.parse(link);

    if (!await launchUrl(url)) {
      Assist.showSnackBar(context, 'Unable to open the specified link: $link');
    }
  }

  ///Opens the specified link as an email link
  static void openEmailLink(BuildContext context, String email) async {
    Assist.log('Starting to open the provided email: $email');

    String link = 'mailto:$email?Subject=Inquiry';

    final Uri url = Uri.parse(link);

    if (!await launchUrl(url)) {
      Assist.showSnackBar(
          context, 'Unable to open the specified email address: $email');
    }
  }

   ///Opens the specified link as a phone link
  static void openTelephoneLink(BuildContext context, String phone) async {
    Assist.log('Starting to open the provided phone: $phone');

    String link = 'tel:$phone';

    final Uri url = Uri.parse(link);

    if (!await launchUrl(url)) {
      Assist.showSnackBar(
          context, 'Unable to dial the specified phone: $phone');
    }
  }
}
