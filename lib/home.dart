import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasecrud/Views/addproducts.dart';
import 'package:firebasecrud/Views/homepage.dart';
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
    const HomePage(),
    const AddProducts(),
  ];

  @override
  void initState() {
    super.initState();
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
            ],
          ),
        ));
  }

  Future<bool> onWillPop() async {
    final shouldPop = await showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "Hey...${currentUser!.displayName}",
              style: TextStyle(color: Colors.grey.shade900),
            ),
            content: Text(
              "Do You Want To Exit Application",
              style: TextStyle(color: Colors.grey.shade600),
            ),
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
                child: const Text(
                  "Exit",
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          );
        });
    return shouldPop ?? false;
  }
}
