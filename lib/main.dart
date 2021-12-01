import 'package:flutter/material.dart';
import 'package:spoorweb_mobile/overzicht.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Spoorweb',
        theme: ThemeData(
            primarySwatch: Colors.red, canvasColor: Color(0xFF383838)),
        home: SafeArea(
            child: Scaffold(
          body: Overzicht(),
        )));
  }
}
