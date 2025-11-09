import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, bool>> getUnlockedAnimals() async {
    if(user == null) return {};

    final snapshot = await _firestore.collection('users').doc(user!.uid).collection('collection').get();

    Map<String, bool> unlocked = {};
    for(var doc in snapshot.docs){
      unlocked[doc.id] =doc['unlocked'] ?? false;
    }
    return unlocked;
  }
}