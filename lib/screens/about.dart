import 'package:flutter/material.dart';
import 'package:twyshe/utils/assist.dart';

///Handles About chanegs by the user
///16 August 2023, Nkole Evans
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
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
        title: const Text(
          'About',
        ),
      ),
      backgroundColor: Colors.purple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Image(
              image: AssetImage('asset/icons/appicon.png'),
              width: 120,
            ),
            Text(Assist.appName,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Padding(padding:  EdgeInsets.fromLTRB(4, 2, 4, 2),
              child: Text(
                'Developed under the study \'Closing HIV and reproductive health gaps: an mhealth peer-delivered intervention for high-risk young women in Zambia\'',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Text('Version 1.0',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('Copyright 2024 University of Colorado. All Rights Reserved',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
