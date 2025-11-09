import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geaux_hackathon_2025/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';



class CollectionPage extends StatefulWidget{
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPage();
}

class _CollectionPage extends State<CollectionPage> {
  Map<String,bool> unlockedAnimals = {};
  String? get userEmail => FirebaseAuth.instance.currentUser?.email;
  String? currentPfp = 'lib/assets/bird_gray.png';

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

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

    void _showChangeDialog() {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseFirestore.instance.
      collection('users').
      doc(user.uid).
      collection('collection').
      get().then((snapshot) {
        final unlocked = snapshot.docs.
        where((doc) => doc['unlocked'] == true).
        map((doc) => 'lib/assets/${doc.id}_color.png').
        toList();

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Choose your profile picture"),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: unlocked.length,
                itemBuilder: (context, index) {
                  final animal = unlocked[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPfp = animal;
                      });
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(animal, fit: BoxFit.cover),
                    )
                  );
                }
              ),
            ),
          );
        }
      );
      });
    }
  


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text("Account"),
                  content: const Text('Do you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async{ 
                        Navigator.pop(context);
                        await signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    )
                  ],
                );
              }
            );
          },
          )
        ],
      ),
      body: Column(
      children: [
        const SizedBox(height: 60),
        GestureDetector(
          onTap: _showChangeDialog,
          child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage(currentPfp!),
            ),
          ),
        Text(
          userEmail ?? 'No email found',
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
        child: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('collection')
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final docs = snapshot.data!.docs;
    Map<String, bool> unlocked = {};
    for (var doc in docs) {
      unlocked[doc.id] = doc['unlocked'] ?? false;
    }

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.all(10),
          children: unlocked.entries.map((entry) {
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
        )
        )
        ],
      ),
      );
    }
  }