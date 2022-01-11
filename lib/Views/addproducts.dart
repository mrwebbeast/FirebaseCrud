import 'package:flutter/material.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({Key? key}) : super(key: key);
  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Crud"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Products Page',
            ),
          ],
        ),
      ), //
    );
  }
}
