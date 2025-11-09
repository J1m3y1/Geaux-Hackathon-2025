import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CollectionPage extends StatefulWidget{
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPage();
}

class _CollectionPage extends State<CollectionPage> {
  Map<String,bool> unlockedAnimals = {};

  @override
  void initState() {
    super.initState();
    fetchUnlockedAnimals();
  }

    void fetchUnlockedAnimals() async {
      final user = FirebaseAuth.instance.currentUser;
      if(user == null) return;
    
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('collection').get();

      Map<String,bool> unlocked = {};
      for(var doc in snapshot.docs){
        print("Fetched doc: ${doc.id} => ${doc.data()}");
        unlocked[doc.id] = doc['unlocked'] ?? false;
      }

      setState(() {
        unlockedAnimals = unlocked;
      }); 
    } 

    String getImagePath(String animalId, bool unlocked) {
      return unlocked ? 'lib/assets/${animalId}_color.png' : 'lib/assets/${animalId}_gray.png';
    }
  


  @override 
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(10),
      children: unlockedAnimals.entries.map((entry) {
        final animalId = entry.key;
        final unlocked = entry.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            getImagePath(animalId, unlocked),
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }
}