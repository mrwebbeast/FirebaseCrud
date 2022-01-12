import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({Key? key}) : super(key: key);

  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser!.uid;

  final addServiceForm = GlobalKey<FormState>();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  late String productName = "";
  late String productPrice = "";
  late String productDescription = "";

  late List usernameList = currentUser!.email!.split("@");
  late String username = usernameList.first;

  late File image;
  late File compressedImage;
  String imagePath = "";
  String compressedImagePath = "";
  late String _uploadedImageURL;
  bool uploadingService = false;
  String createCryptoRandomString([int length = 32]) {
    final Random _random = Random.secure();
    var values = List.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,
        actions: [
          TextButton(
              onPressed: uploadingService == true
                  ? () {}
                  : () {
                      uploadData();
                    },
              child: uploadingService == true ? const Text("Uploading...") : const Text("Publish")),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
            key: addServiceForm,
            child: Column(
              children: [
                imagePath.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey,
                              )),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 170,
                                      width: double.infinity / 2,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                          )),
                                      child: Image.file(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.image),
                                          TextButton(
                                              onPressed: () {
                                                getImage();
                                              },
                                              child: const Text(
                                                "Change Photo",
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    imagePath.isNotEmpty
                                        ? Center(
                                            child: Text(
                                              "Original Image Size \n${(image.lengthSync() / 1024).toStringAsFixed(0)} Kb",
                                              style: const TextStyle(color: Colors.blue),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : const Text("Size"),
                                    compressedImagePath.isNotEmpty
                                        ? Text(
                                            "Compressed Image Size \n${(compressedImage.lengthSync() / 1024).toStringAsFixed(0)} Kb",
                                            style: const TextStyle(color: Colors.green),
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text("Size"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          getImage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                  color: Colors.grey.shade900,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Add Photo",
                                  style: TextStyle(
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        "Product Detail",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: productNameController,
                    decoration: InputDecoration(
                      labelText: "Product Name",
                      hintText: "Product Name",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Product Name";
                      } else if (val.length < 2) {
                        return "Please Enter valid Product Name";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: productPriceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      labelText: "Product Price",
                      hintText: "Product Price",
                      prefix: const Text("\$ "),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Product Price ";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: productDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Product Description",
                      hintText: "Product Description",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Product Description";
                      } else if (val.length < 20) {
                        return "Product Description must Contain 20 Words";
                      }
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Future<void> getImage() async {
    final pickedImg = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedImg!.path);
      imagePath = pickedImg.path.toString();
    });
    compressedImage = await compressImage(imagePath: image);
    setState(() {
      compressedImagePath = compressedImage.path;
    });
  }

  Future<File> compressImage({required File imagePath}) async {
    var path = await FlutterNativeImage.compressImage(imagePath.path, quality: 100, percentage: 25);
    return path;
  }

  Future<void> uploadData() async {
    if (addServiceForm.currentState!.validate()) {
      if (imagePath.isNotEmpty) {
        setState(() {
          uploadingService = true;
          productName = productNameController.text;
          productPrice = productPriceController.text;
          productDescription = productDescriptionController.text;
        });
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showMaterialBanner(
            MaterialBanner(
              leading: const SafeArea(
                child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
              ),
              content: const SafeArea(
                child: Text(
                  "Uploading...",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              actions: [
                SafeArea(
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
          );
        String fileName = image.path.split("/").last;
        final storage = FirebaseStorage.instance.ref().child("Users/$uid/ProductImages/$fileName");
        final uploadTask = storage.putFile(compressedImage);
        await uploadTask.whenComplete(() {
          storage.getDownloadURL().then((fileURL) {
            _uploadedImageURL = fileURL;
            if (_uploadedImageURL.isNotEmpty) {
              dynamic id = createCryptoRandomString(32);
              fireStore.collection("Users").doc(uid).collection("Products").doc(id).set(
                {
                  "ID": id,
                  "Name": productName,
                  "Price": productPrice,
                  "Description": productDescription,
                  "ProductImage": _uploadedImageURL
                },
              ).then(
                (value) {
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
                            "$productName Added  Successfully",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {
                    imageCache!.clear();
                    id = createCryptoRandomString(32);
                    productNameController.clear();
                    productPriceController.clear();
                    productDescriptionController.clear();
                    uploadingService = false;
                  });
                },
              );
            } else {
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
                        "Image Failed to Upload",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        });
      } else {
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
                  "Select an Image",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
