import 'dart:math';
import 'dart:async';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:intl/intl.dart';
import 'package:twyshe/classes/converation.dart';
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

  ///The key used in preferences for a color
  static const defaultColor = '#7B1FA2';

  ///The key used in preferences for a color
  static const defaultName = 'Peer Navigator';

  ///The active api URL of the app
  static const apiUrl = 'https://nkoleevans.pythonanywhere.com';

  //The local URL for the api
  static const localApiUrl = 'http://10.0.2.2:3100';

  //The online  URL for the api
  static const onlineApiUrl = 'https://nkoleevans.pythonanywhere.com';

  ///The active file web URL of the app
  static const fileServerUrl = 'https://twyshe.app/files';

  ///The active api key for the web URL of the app
  static const fileServerKey = 'zyKROQ8sMMx676HLah3t9zaaPNtfXyrf';

  ///The active upload task for the web URL of the app
  static const fileServerUploadTask = 'UploadFile';

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

  ///The key used in preferences for a status
  static const statusKey = 'status';

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

  ///The key used in firestore to store the users
  static const firestoreUsersKey = 'twyshe-users';

  ///The key used in firestore to store the chat for peer navigators
  static const firestorePeerNavigatorDiscussionKey =
      'peer-navigator-discussion';

  ///The status of the message which is active
  static const messageStateActive = 1;

  ///The status of the message which is deleted
  static const messageStateDeleted = 2;

  ///The key for the FCM token
  static const String fcmTokenKey = 'fcmtoken';

  ///The status of the participant
  static const userParticipant = 3;

  ///The status of the peer navigator
  static const userPeer = 2;

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

  static int getDateStatus(DateTime date) {
    DateTime cleanDate = DateTime(date.year, date.month, date.day);

    DateTime nowCurrent =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime nowYesterday = nowCurrent.add(const Duration(days: -1));

    if (cleanDate == nowCurrent) {
      return 0;
    } else if (cleanDate == nowYesterday) {
      return -1;
    } else {
      return 1;
    }
  }

  static String getLastSeen(Timestamp? timestamp, bool never) {
    if (never) {
      return 'Never been online';
    } else {
      if (timestamp == null) {
        return '';
      } else {
        DateTime date1 = timestamp.toDate();
        DateTime date2 = DateTime.now();

        int seconds = date2.difference(date1).inSeconds;

        if (seconds <= 10) {
          return 'Online';
        } else {
          int status = Assist.getDateStatus(date1);

          if (status == 0) {
            return "Today, ${DateFormat("HH:mm").format(date1.toLocal())}";
          } else if (status == -1) {
            return "Yesterday, ${DateFormat("HH:mm").format(date1.toLocal())}";
          } else {
            return DateFormat("d MMM yyy H:m").format(date1.toLocal());
          }
        }
      }
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
    int currentStatus =
        prefs.getInt(Assist.statusKey) ?? Assist.userParticipant;

    TwysheUser user = TwysheUser(
        phone: currentPhone,
        nickname: currentNickname,
        color: currentColor,
        pin: currentPin,
        status: currentStatus);

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
      String pin, String nickname, String color, int status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? initialPin = prefs.getString(Assist.pinKey);
    String? initialNickname = prefs.getString(Assist.nicknameKey);
    String? initialColor = prefs.getString(Assist.colorKey);
    int? initialStatus = prefs.getInt(Assist.statusKey);

    await prefs.setString(Assist.pinKey, pin);
    await prefs.setString(Assist.nicknameKey, nickname);
    await prefs.setString(Assist.colorKey, color);
    await prefs.setInt(Assist.statusKey, status);

    String? currentPin = prefs.getString(Assist.pinKey);
    String? currentNickname = prefs.getString(Assist.nicknameKey);
    String? currentColor = prefs.getString(Assist.colorKey);
    int? currentStatus = prefs.getInt(Assist.statusKey);

    String initials =
        'Nickname: $initialNickname, Color: $initialColor, PIN: $initialPin, Status: $initialStatus';

    String currents =
        'Nickname: $currentNickname, Color: $currentColor, PIN: $currentPin, Status: $currentStatus';

    Assist.log(
        'The profile has been updated. Initial values; $initials, Currents: $currents');

    return true;
  }

  static void updateUserStatus({
    required TwysheUser twysheUser,
    required bool typing,
  }) {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreUsersKey)
        .collection(Assist.firestoreUsersKey)
        .doc(twysheUser.phone)
        .set({
      'typing': typing,
      'timestamp': Timestamp.now(),
      'name': twysheUser.nickname,
      'color': twysheUser.color,
      'pin': twysheUser.pin,
      'status': twysheUser.status
    }).then((resPost) {
      Assist.log(
          'The user \'${twysheUser.phone}\' has been successfully updated to typing \'$typing\' and timestamp \'${Timestamp.now()}\'');
    }).onError((resError, stackTrace) {
      Assist.log(
          'Unable to update the user \'${twysheUser.phone}\' to typing \'$typing\' and timestamp \'${Timestamp.now()}\': $resError');
    });
  }

  static void updateChatMessageStatus(
      {required String messageRef,
      required String? text,
      required Status status,
      required TwysheConversation? conversation,
      required TwysheUser twysheUser}) {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(conversation!.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(messageRef)
        .update({
      'status': status.name,
    }).then((resPost) {
      Assist.log(
          'The message \'$messageRef\' has been successfully updated to \'${status.name}\'');

      Assist.updateOwnConversation(
          message: text, conversation: conversation, twysheUser: twysheUser);

      Assist.updateOtherConversation(
          message: text, conversation: conversation, twysheUser: twysheUser);
    }).onError((resError, stackTrace) {
      Assist.log(
          'Unable to update message \'$messageRef\' to status \'${status.name}\': $resError');
    });
  }

  static Message getSnapShotMessage(
      {required DocumentSnapshot document,
      required bool chat,
      required TwysheUser twysheUser,
      required TwysheConversation? conversation}) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    //get ref
    String ref = document.id;

    //set user
    String userId = data['author']['id'];
    String userFirstName = data['author']['firstName'];
    String? userLastName = data['author']['lastName'];

    String peerNavigator = '';

    Map<String, dynamic> authorData = data['author'] as Map<String, dynamic>;

    if (authorData.containsKey('type')) {
      int type = authorData['type'];

      if (type == Assist.userPeer) {
        peerNavigator = ' [PN]';
      }
    }

    User messageUser = User(
      id: userId,
      firstName: '$userFirstName$peerNavigator',
      lastName: userLastName,
    );

    //text message
    Timestamp messageCreatedAt = data['createdAt'];

    String messageStatus = data['status'];

    String messageType = data['type'];

    String sender = data['sender'];

    String? messageText = data['text'];

    //check if message belongs to one to one chat needs to be marked as seen
    if (chat &&
        messageStatus == Status.sent.name &&
        sender.compareTo(twysheUser.phone) != 0) {
      Assist.updateChatMessageStatus(
          messageRef: ref,
          text: messageText,
          status: Status.seen,
          conversation: conversation,
          twysheUser: twysheUser);
    }

    if (messageType == "text") {
      var textMessage = types.TextMessage(
          author: messageUser,
          createdAt: messageCreatedAt.millisecondsSinceEpoch,
          id: ref,
          text: messageText!,
          status: messageStatus == "seen" ? Status.seen : Status.sent,
          type: MessageType.text);

      return textMessage;
    } else if (messageType == "image") {
      String uri = data['uri'];
      int size = data['size'];
      String name = data['name'];

      var textMessage = types.ImageMessage(
          author: messageUser,
          createdAt: messageCreatedAt.millisecondsSinceEpoch,
          id: ref,
          uri: uri,
          name: name,
          size: size,
          status: messageStatus == "seen" ? Status.seen : Status.sent,
          type: MessageType.image);
      return textMessage;
    } else {
      String uri = data['uri'];
      int size = data['size'];
      String name = data['name'];
      String mimeType = data['mimeType'];

      var textMessage = types.FileMessage(
          author: messageUser,
          createdAt: messageCreatedAt.millisecondsSinceEpoch,
          id: ref,
          uri: uri,
          name: name,
          mimeType: mimeType,
          size: size,
          status: messageStatus == "seen" ? Status.seen : Status.sent,
          type: MessageType.file);

      return textMessage;
    }
  }

  ///update own conversation
  static void updateOwnConversation(
      {required String? message,
      required TwysheConversation conversation,
      required TwysheUser twysheUser}) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(conversation.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .where('status', isEqualTo: Status.sent.name)
        .where('sender', isEqualTo: conversation.otherPhone)
        .count()
        .get()
        .then((resCount) {
      FirebaseFirestore.instance
          .collection(Assist.firestoreAppCode)
          .doc(Assist.firestoreConversationsKey)
          .collection(Assist.firestoreConversationsKey)
          .doc(twysheUser.phone)
          .collection(Assist.firestoreConversationsKey)
          .doc(conversation.otherPhone)
          .set(<String, dynamic>{
        'id': conversation.ref,
        'owner': twysheUser.phone,
        'color': twysheUser.color,
        'other_phone': conversation.otherPhone,
        'other_name': conversation.otherName,
        'name': 'You',
        'count': resCount.count,
        'message': message,
        'posted': Timestamp.now(),
        'status': 1,
        'typing': ''
        //'posts': 0,
      }).then((value) {
        Assist.log(
            'The conversation \'${conversation.ref}\' has been successfully updated!');
      }).onError((error, stackTrace) {
        Assist.log(
            'Unable to update the conversation for user ${twysheUser.phone} and recipient ${conversation.otherPhone}: $error');
      });
    }).onError((errorCount, st) {
      Assist.log(
          'Error counting posts for the conversation \'${conversation.ref}\': $errorCount');
    });
  }

  //update other conversation
  static void updateOtherConversation(
      {required String? message,
      required TwysheConversation conversation,
      required TwysheUser twysheUser}) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationChatsKey)
        .collection(Assist.firestoreConversationChatsKey)
        .doc(conversation.ref)
        .collection(Assist.firestoreConversationChatsKey)
        .where('status', isEqualTo: Status.sent.name)
        .where('sender', isEqualTo: twysheUser.phone)
        .count()
        .get()
        .then((resCount) {
      FirebaseFirestore.instance
          .collection(Assist.firestoreAppCode)
          .doc(Assist.firestoreConversationsKey)
          .collection(Assist.firestoreConversationsKey)
          .doc(conversation.otherPhone)
          .collection(Assist.firestoreConversationsKey)
          .doc(twysheUser.phone)
          .set(<String, dynamic>{
        'id': conversation.ref,
        'owner': conversation.otherPhone,
        'color': twysheUser.color,
        'other_phone': twysheUser.phone,
        'other_name': twysheUser.nickname,
        'name': twysheUser.nickname,
        'count': resCount.count,
        'message': message,
        'posted': Timestamp.now(),
        'status': 1,
        'typing': ''
        //'posts': 0,
      }).then((value) {
        Assist.log(
            'The conversation \'${conversation.ref}\' has been successfully updated!');
      }).onError((error, stackTrace) {
        Assist.log(
            'Unable to update the conversation for user ${conversation.otherPhone} and sender ${twysheUser.phone}: $error');
      });
    }).onError((errorCount, st) {
      Assist.log(
          'Error counting posts for the conversation \'${conversation.ref}\': $errorCount');
    });
  }

  //update other conversation
  static void updateOtherConversationStatus(
      {required String typing,
      required TwysheConversation conversation,
      required TwysheUser twysheUser}) async {
    FirebaseFirestore.instance
        .collection(Assist.firestoreAppCode)
        .doc(Assist.firestoreConversationsKey)
        .collection(Assist.firestoreConversationsKey)
        .doc(conversation.otherPhone)
        .collection(Assist.firestoreConversationsKey)
        .doc(twysheUser.phone)
        .update(<String, dynamic>{
      'typing': typing,
      //'posts': 0,
    }).then((value) {
      Assist.log(
          'The conversation \'${conversation.ref}\' has been successfully updated!');
    }).onError((error, stackTrace) {
      Assist.log(
          'Unable to update the conversation for user ${conversation.otherPhone} and sender ${twysheUser.phone}: $error');
    });
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
