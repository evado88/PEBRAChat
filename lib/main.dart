import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:twyshe/firebase_options.dart';
import 'package:twyshe/screens/home.dart';
import 'package:twyshe/screens/register.dart';
import 'package:twyshe/utils/assist.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//Main entry point for app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ///Assist.removeUser();// Uncomment in prod
  String phone = await Assist.getUser();
  String token = await Assist.getFCMToken();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? fcmToken = await FirebaseMessaging.instance.getToken();

  ///subscribe to all app wide notifications
  Assist.subscribeTopic(Assist.appCode);

  ///only save the token if its not null and different from current one
  if (fcmToken != null && token != fcmToken) {
    Assist.saveFCMToken(fcmToken);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    ///save the new token
    Assist.saveFCMToken(fcmToken);
  }).onError((err) {
    // Error getting token.
    Assist.log('Unable to retrieve refreshed FCM token: $err');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    Assist.log('Got a message whilst in the foreground!');
    Assist.log('Message data: ${message.data}');

    if (message.notification != null) {
      Assist.log(
          'Message also contained a notification: ${message.notification!.toMap()}');
    }
  });

  runApp(MyApp(
    registeredPhone: phone,
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Assist.log("Handling a background message: ${message.toMap()}");
}

class MyApp extends StatelessWidget {
  final String registeredPhone;

  const MyApp({super.key, required this.registeredPhone});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twyshe Messenger',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: Assist.isRegistered(registeredPhone)
          ? const HomePage(title: Assist.appName)
          : const RegisterPage(title: 'Register'),
      //initialRoute: '/', this is not needed if home is defined
      routes: {
        '/register': (context) => const RegisterPage(title: 'Register'),
      },
    );
  }
}
