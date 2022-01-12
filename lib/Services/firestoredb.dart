import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreDB {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User? currentUser = FirebaseAuth.instance.currentUser;

  static deleteProduct({required String id, required String uid}) {
    fireStore.collection("Users").doc(uid).collection("Products").doc(id).delete();
  }
}
