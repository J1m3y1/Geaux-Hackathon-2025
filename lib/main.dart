import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Grass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(30.40777, -91.17972);
  final Set<Marker> _markers = {};
  late BitmapDescriptor grassIcon;

  final Map<String,DateTime> lastTouched = {};
  List<String> selectedAnimals = [
    'lib/animals/brown_cat.png',
    'lib/animals/rat.png',
    'lib/animals/bird.png',
    'lib/animals/brown_squirrel.png',
    'lib/animals/brown_dog.png',
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
    BitmapDescriptor newIcon = await getScaledMarker('lib/icons/grass.png', scale);

    setState(() {
      _markers.clear();
      _addMarkers(newIcon);
    });
  }

  void _handleMarkerTap(String markerId) {
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
    grassIcon = await getScaledMarker('lib/icons/grass.png', scale);
    
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
  void initState() {
    super.initState();
    _loadCustomMarker(1.25);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onCameraMove: _onCameraMove,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: _markers,

      ),
    );
  }
}
  
