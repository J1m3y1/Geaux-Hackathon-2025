import 'package:flutter/material.dart';
import 'package:geaux_hackathon_2025/pages/collection_page.dart';
import 'package:geaux_hackathon_2025/pages/shop_page.dart';
import 'package:geaux_hackathon_2025/pages/map_page.dart';

class MainNavigation extends StatefulWidget{
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigation();
}

class _MainNavigation extends State<MainNavigation> {
  int myIndex = 0;

  final List<Widget> screens = [
    const MapPage(title: 'Map'),
    GameShopScreen(),
    CollectionPage(),
  ];

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: myIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Collection',
          ),
        ],
    ),
    );
}
}
