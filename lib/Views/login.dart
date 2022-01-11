import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Services/authentication.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static bool isLoading = false;
  late String email, password;
  final loginFormKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    await Authentication.signInWithGoogle(context: context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Firebase Crud",
          style: TextStyle(color: Colors.grey.shade500),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Processing...")
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: loginFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SIGN IN",
                        style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30,
                      ),

                      const SizedBox(height: 10),
//Google Login Button
                      Card(
                        child: SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: const Center(child: Text("MrWebBeast")),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          signInWithGoogle();
                        },
                        child: Center(
                          child: Image.asset(
                            "assets/images/btn_google_signin.png",
                            height: 45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
