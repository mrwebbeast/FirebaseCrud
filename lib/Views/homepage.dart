import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasecrud/Services/authentication.dart';
import 'package:firebasecrud/Services/editproduct.dart';
import 'package:firebasecrud/Services/firestoredb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseStorage storage = FirebaseStorage.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Products"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.grey.shade600,
            backgroundImage: NetworkImage("${currentUser!.photoURL}"),
          ),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (item) => selectedItem(context, item),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.logout),
                      Text("Sign Out"),
                    ],
                  )),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          FirebaseFirestore.instance.collection('Users').doc(uid).collection("Products");
        },
        child: FirestoreQueryBuilder<Map<String, dynamic>>(
          pageSize: 10,
          query: FirebaseFirestore.instance.collection('Users').doc(uid).collection("Products"),
          builder: (context, snapshot, _) {
            if (snapshot.isFetching) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong! ${snapshot.error}'));
            }

            return snapshot.docs.isNotEmpty
                ? ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }
                      Map<String, dynamic> data = snapshot.docs[index].data();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
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
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Text(
                                                    data["Name"],
                                                    style: TextStyle(
                                                        color: Colors.grey.shade700,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
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
                                        ),
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
                                              id: data["ID"],
                                              name: data["Name"],
                                              imageUrl: data["ProductImage"]);
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
                    },
                  )
                : const Center(child: Text("No product Available...yet"));
          },
        ),
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
                    FireStoreDB.deleteProduct(id: id, uid: uid);
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

  void selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                  "Hey ${currentUser!.displayName}",
                  style: TextStyle(color: Colors.grey.shade900),
                ),
                content: Text(
                  "Do You Want To Logout",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
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
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              );
            });
        break;
    }
  }
}
