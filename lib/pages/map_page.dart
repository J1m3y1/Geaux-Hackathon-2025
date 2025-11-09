import 'package:flutter/services.dart';
import 'package:geaux_hackathon_2025/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import 'dart:math';


class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  late GoogleMapController mapController;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    getUserLocation();
    _loadCustomMarker(1.25);
  }


Future<void> getUserLocation() async {
    try {
      final locationService = LocationService();
      final pos = await locationService.getCurrentLocation();

      setState(() {
        _userPosition = pos;
      });
    // ignore: empty_catches
    } catch (e) {}
    
  }

  final Set<Marker> _markers = {};
  late BitmapDescriptor grassIcon;

  final Map<String,DateTime> lastTouched = {};
  List<String> selectedAnimals = [
    'lib/assets/bird_color.png',
    'lib/assets/rat_color.png',
    'lib/assets/cat_color.png',
    'lib/assets/dog_color.png',
    'lib/assets/squirrel_color.png',
  ];

Future<BitmapDescriptor> getScaledMarker(String assetPath, double scale) async {
  ByteData byteData = await rootBundle.load(assetPath);
  ui.Codec codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(), targetWidth: (150 * scale).toInt());
  ui.FrameInfo fi = await codec.getNextFrame();
  ByteData? resizedData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());}

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) async {
    double zoom = position.zoom;
    double scale = ((zoom - 15) / 5).clamp(0.01, 10.0); 
    BitmapDescriptor newIcon = await getScaledMarker('lib/assets/grass.png', scale);

    setState(() {
      _markers.clear();
      _addMarkers(newIcon);
    });
  }

  Future<void> _handleMarkerTap(String markerId) async {
    DateTime now = DateTime.now();

    if (lastTouched.containsKey(markerId)) {
      final lastTap = lastTouched[markerId]!;
      final difference = now.difference(lastTap);
      if (difference.inHours < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$markerId is on cooldown. Go Touch more grass.')),
        );
        return;
      }
    }

    lastTouched[markerId] = now;

    String randomAnimal = selectedAnimals[Random().nextInt(selectedAnimals.length)];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.asset(randomAnimal, width: 150, height: 150),
        );
      },
    );

    // Update Firestore to unlock this animal for the current user
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Extract animal name from the asset path (e.g., "bird_color.png" → "bird")
  String animalId = randomAnimal.split('/').last.split('_').first;

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('collection')
      .doc(animalId);

  // Mark as unlocked in Firestore
  await docRef.set({'unlocked': true}, SetOptions(merge: true));
  }

  void _addMarkers(BitmapDescriptor icon) {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('Student Union'),
        position: const LatLng(30.41263, -91.17712),
        infoWindow: const InfoWindow(title: 'Student Union'),
        icon: icon,
        onTap: () => _handleMarkerTap('Student Union'),
      ),
      Marker(
        markerId: const MarkerId('Parade Ground'),
        position: const LatLng(30.41468, -91.17719),
        infoWindow: const InfoWindow(title: 'Parade Ground'),
        icon: icon,
        onTap: () => _handleMarkerTap('Parade Ground'),
      ),
       Marker(
        markerId: const MarkerId('Parade Ground lower'),
        position: const LatLng(30.41367, -91.17719),
        infoWindow: const InfoWindow(title: 'Parade Ground lower'),
        icon: icon,
        onTap: () => _handleMarkerTap('Parade Ground lower'),
      ),
      Marker(
        markerId: const MarkerId('Patrick Taylor Hall'),
        position: const LatLng(30.40777, -91.17972),
        infoWindow: const InfoWindow(title: 'Patrick Taylor Hall'),
        icon: icon,
        onTap: () => _handleMarkerTap('Patrick Taylor Hall'),
      ),
      Marker(
        markerId: const MarkerId('Quad'),
        position: const LatLng(30.41336, -91.18005),
        infoWindow: const InfoWindow(title: 'Quad'),
        icon: icon,
        onTap: () => _handleMarkerTap('Quad'),
      ),
      Marker(
        markerId: const MarkerId('UREC'),
        position: const LatLng(30.41174, -91.16900),
        infoWindow: const InfoWindow(title: 'UREC'),
        icon: icon,
        onTap: () => _handleMarkerTap('UREC'),
      ),
      Marker(
        markerId: const MarkerId('Death Valley'),
        position: const LatLng(30.41196, -91.18399),
        infoWindow: const InfoWindow(title: 'Death Valley'),
        icon: icon,
        onTap: () => _handleMarkerTap('Death Valley'),
      ),


    ]);
  }

  void _loadCustomMarker(double scale) async { 
    grassIcon = await getScaledMarker('lib/assets/grass.png', scale);
    
    setState(() {
      _markers.clear();
      _markers.addAll([
        Marker(
          markerId: const MarkerId('Student Union'),
          position: const LatLng(30.41263, -91.17712),
          infoWindow: const InfoWindow(title: 'Student Union'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Student Union'),
        ),
        Marker(
          markerId: const MarkerId('Parade Ground Upper'),
          position: const LatLng(30.41468, -91.17719),
          infoWindow: const InfoWindow(title: 'Parade Ground Upper'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Parade Ground Upper'),
        ),
         Marker(
          markerId: const MarkerId('Parade Ground lower'),
          position: const LatLng(30.41367, -91.17719),
          infoWindow: const InfoWindow(title: 'Parade Ground lower'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Parade Ground lower'),
        ),
        Marker(
          markerId: const MarkerId('Patrick Taylor Hall'),
          position: const LatLng(30.40777, -91.17972),
          infoWindow: const InfoWindow(title: 'Patrick Taylor Hall'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Patrick Taylor Hall'),
        ),
        Marker(
          markerId: const MarkerId('Quad'),
          position: const LatLng(30.41336, -91.18005),
          infoWindow: const InfoWindow(title: 'Quad'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Quad'),
        ),
        Marker(
          markerId: const MarkerId('UREC'),
          position: const LatLng(30.41174, -91.16900),
          infoWindow: const InfoWindow(title: 'UREC'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('UREC'),
        ),
        Marker(
          markerId: const MarkerId('Death Valley'),
          position: const LatLng(30.41196, -91.18399),
          infoWindow: const InfoWindow(title: 'Death Valley'),
          icon: grassIcon,
          onTap: () => _handleMarkerTap('Death Valley'),
        ),

      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final LatLng center = LatLng(_userPosition!.latitude, _userPosition!.longitude);
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onCameraMove: _onCameraMove,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 14.0,
        ),
         markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
      ),
    );
  }
}