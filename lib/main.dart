import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notevault1/pages/home.dart';
import 'package:notevault1/pages/login.dart';
import 'package:notevault1/pages/notesview.dart';
//import 'package:notevault1/pages/profile.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const HomeScreen(),
        '/notesview': (context) => const Notesview(),
        //'/profile': (context) => const (),
      },
    ),
  );
}
