import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShopItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;

  ShopItem({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });
}

class GameShopScreen extends StatefulWidget {
  const GameShopScreen({super.key});

  @override
  State<GameShopScreen> createState() => _GameShopScreenState();
}

class _GameShopScreenState extends State<GameShopScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final List<ShopItem> items = [
    ShopItem(
      name: 'Water Sprinkler',
      description: 'The grass is greener where you water it.',
      price: 200,
      icon: Icons.water_drop,
      color: Colors.blue,
    ),
    ShopItem(
      name: 'Fertilizer Bag',
      description: 'If you go out and poop on grass they grow faster',
      price: 350,
      icon: Icons.compost,
      color: Colors.brown,
    ),
    ShopItem(
      name: 'Garden Rake',
      description: 'You can touch grass from far away.',
      price: 250,
      icon: Icons.agriculture,
      color: Colors.orange,
    ),
    ShopItem(
      name: 'Lucky Clover',
      description: 'Double grass touch rewards for 30 minutes!',
      price: 750,
      icon: Icons.filter_vintage,
      color: Colors.green,
    ),
  ];

  Future<void> purchaseItem(ShopItem item, int currentBalance) async {
    if (user == null) return;

    if (currentBalance >= item.price) {
      int newBalance = currentBalance - item.price;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'balance': newBalance});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchased ${item.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d4a2d),
        elevation: 0,
        title: const Text(
          'Grass Shop',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFe8f5e9),
          ),
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              int balance = snapshot.data!['balance'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF558b2f),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/grass.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          int balance = snapshot.data!['balance'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: const Color(0xFF3d5a3d),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFF4a6e4a),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => purchaseItem(item, balance),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 40,
                              color: item.color,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Color(0xFFe8f5e9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  color: Color(0xFFe8f5e9),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF558b2f),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/grass.png',
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.price}',
                                  style: const TextStyle(
                                    color: Color(0xFFC8E6C9),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
