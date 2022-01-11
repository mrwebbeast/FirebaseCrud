import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasecrud/Views/addproducts.dart';
import 'package:firebasecrud/Views/homepage.dart';
import 'package:firebasecrud/Views/mysettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late Map fetchedImages = {};
  int pageIndex = 0;
  static List<Widget> navBarPages = <Widget>[
    const Homepage(),
    const AddProducts(),
    const MySettings(),
  ];

  @override
  void initState() {
    super.initState();
    print("init Home Screen");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          body: IndexedStack(
            index: pageIndex,
            children: navBarPages,
          ),
          bottomNavigationBar: CupertinoTabBar(
            iconSize: 24,
            currentIndex: pageIndex,
            activeColor: CupertinoColors.activeBlue,
            onTap: (newIndex) {
              setState(() {
                pageIndex = newIndex;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.briefcase_fill),
                label: "Products",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: "Setting",
              ),
            ],
          ),
        ));
  }

  Future<bool> onWillPop() async {
    final shouldPop = await showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Hey...${currentUser!.displayName}"),
            content: const Text("Do You Want To Exit Application"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Yes"),
              )
            ],
          );
        });
    return shouldPop ?? false;
  }
}