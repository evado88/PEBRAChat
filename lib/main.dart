import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/firebase_options.dart';
import 'package:kitchen/screens/home.dart';
import 'package:kitchen/screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const HomePage(title: 'Twyshe Messenger'),
      //initialRoute: '/', this is not needed if home is defined
      routes: {
        '/register': (context) => const RegisterPage(title: 'Register'),
      },
    );
  }
}



