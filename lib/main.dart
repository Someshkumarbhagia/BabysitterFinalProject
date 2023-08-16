import 'package:babysitter/views/babysitter/babysitter_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:babysitter/firebase_options.dart';
import 'package:babysitter/views/auth/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var homeScreen =
      prefs.getString("email") == null ? LoginScreen() : BabysitterHome();
  runApp(
    MyApp(
      homeScreen: homeScreen,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;

  MyApp({required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Babysitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: "DGO",
      ),
      home: homeScreen,
    );
  }
}
