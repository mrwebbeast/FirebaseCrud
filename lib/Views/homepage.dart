import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasecrud/Services/editProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  late String uid = currentUser!.uid;
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Firebase Crud"),
        actions: [
          Padding(
            padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
            child: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.orangeAccent,
              backgroundImage: NetworkImage("${currentUser!.photoURL}"),
              radius: 20,
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .collection("Products")
            .limit(10)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xff34aaad),
                                    foregroundColor: const Color(0xff34aaad),
                                    backgroundImage: NetworkImage("${currentUser!.photoURL}"),
                                    radius: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Row(
                                      children: [
                                        Text(
                                          data["Name"],
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "\$${data["Price"]}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          CachedNetworkImage(
                            height: 350,
                            fadeOutDuration: const Duration(milliseconds: 100),
                            fadeInDuration: const Duration(milliseconds: 50),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: data["ProductImage"],
                            placeholder: (context, url) {
                              return Container(
                                  height: 250,
                                  color: Colors.grey.shade300,
                                  width: double.infinity,
                                  child: const Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 15,
                                    ),
                                  ));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      "Description:- ${data["Description"]}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  deleteProduct(
                                      id: data["ID"], name: data["Name"], imageUrl: data["ProductImage"]);
                                },
                                icon: const Icon(
                                  CupertinoIcons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  editProduct(
                                      id: data["ID"],
                                      name: data["Name"],
                                      price: data["Price"],
                                      description: data["Description"],
                                      imageUrl: data["ProductImage"]);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }).toList(),
          );
        },
      ), //
    );
  }

  void deleteProduct({
    required String id,
    required String name,
    required String imageUrl,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text(
                name,
                style: const TextStyle(color: Colors.blue),
              ),
              content: deleting == true
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                        Text("Deleting Product...$name "),
                      ],
                    )
                  : Text("Do You Want To Delete Product $name "),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      deleting = true;
                    });
                    fireStore.collection("Users").doc(uid).collection("Products").doc(id).delete();
                    storage.refFromURL(imageUrl).delete().whenComplete(() {
                      setState(() {
                        deleting = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(10),
                          shape: const StadiumBorder(),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$name Service Deleted Successfully",
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            );
          });
        });
  }

  void editProduct({
    required String id,
    required String name,
    required String price,
    required String description,
    required String imageUrl,
  }) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return EditProduct(
            uid: uid,
            productId: id,
            productName: name,
            productPrice: price,
            productDesc: description,
          );
        });
  }
}
