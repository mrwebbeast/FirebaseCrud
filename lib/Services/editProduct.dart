import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProduct extends StatefulWidget {
  final String uid;
  final String productId;
  final String productName;
  final String productPrice;
  final String productDesc;

  const EditProduct({
    Key? key,
    required this.uid,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productDesc,
  }) : super(key: key);
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late String uid = widget.uid;
  late String id = widget.productId;
  late String name = widget.productName;
  late String price = widget.productPrice;
  late String desc = widget.productDesc;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  bool updating = false;

  GlobalKey<FormState> updateServiceForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff757575),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        child: Form(
            key: updateServiceForm,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 36, 8, 8),
                  child: Center(
                    child: Text(
                      updating == true ? "Updating Product..." : "Edit Product",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    initialValue: name,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Name";
                      } else if (val.length < 2) {
                        return "Please Enter valid Name";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    initialValue: price,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        price = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Price",
                      hintText: "Price",
                      prefix: const Text("\$ "),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Price ";
                      } else if (val.length > 10) {
                        return "Seems to be OverPriced";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    initialValue: desc,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        desc = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Description",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Description";
                      } else if (val.length < 20) {
                        return "Description must Contain 20 Words";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom, top: 8, left: 8, right: 8),
                  child: Center(
                    child: updating == true
                        ? const CircularProgressIndicator()
                        : CupertinoButton(
                            child: const Text("Update"),
                            color: Colors.blue,
                            onPressed: () {
                              updateProduct(id: id);
                              setState(() {
                                updating = true;
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            )),
      ),
    );
  }

  Future<void> updateProduct({required String id}) async {
    if (updateServiceForm.currentState!.validate()) {
      fireStore.collection("Users").doc(uid).collection("Products").doc(id).update({
        "Name": name,
        "Price": price,
        "Description": desc,
      }).then(
        (value) {
          setState(() {
            updating = false;
          });
          Navigator.pop(context);
        },
      );
    }
  }
}
