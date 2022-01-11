import 'package:firebase_core/firebase_core.dart';
import 'package:firebasecrud/Views/addproducts.dart';
import 'package:firebasecrud/Views/homepage.dart';
import 'package:firebasecrud/Views/login.dart';
import 'package:firebasecrud/Views/mysettings.dart';
import 'package:firebasecrud/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Controllers/loginstatus.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LoginStatus.prefs = await SharedPreferences.getInstance();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Crud',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.grey.shade600),
          toolbarTextStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginStatus.prefs.getBool("isLoggedIN") == true ? const Home() : const Login(),
      routes: {
        "/home": (context) => const Home(),
        "/homePage": (context) => const Homepage(),
        "/addProducts": (context) => const AddProducts(),
        "/settings": (context) => const MySettings(),
        "/login": (context) => const Login(),
      },
    );
  }
}
