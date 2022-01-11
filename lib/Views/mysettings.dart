import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasecrud/Services/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  MySettingsState createState() => MySettingsState();
}

class MySettingsState extends State<MySettings> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final currentUser = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final profilePicURL = "${FirebaseAuth.instance.currentUser!.photoURL}";
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                width: 100,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profilePicURL),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${currentUser?.displayName}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Authentication.signOut(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      margin: const EdgeInsets.all(10),
                      shape: const StadiumBorder(),
                      duration: const Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Successfully Logout",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Card(
                    color: Colors.grey.shade100,
                    margin: EdgeInsets.zero,
                    child: const ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Colors.blue,
                      ),
                      trailing: Icon(
                        CupertinoIcons.arrow_right,
                        color: Colors.black,
                      ),
                      title: Text("Logout"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
