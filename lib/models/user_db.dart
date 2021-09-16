import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('users');
  Future updateUserData(String name, String email, String userName) async {
    return await collection
        .doc(uid)
        .set({'name': name, 'email': email, 'userName': userName});
  }
}
