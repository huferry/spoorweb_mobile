import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Overzicht extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Expanded(child: IncidentMap()), IncidentInfo()],
    );
  }
}

class IncidentMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20), child: MapDisplay()),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(15, 15);
    path.lineTo(15, size.height - 15);
    path.lineTo(size.width - 15, size.height - 15);
    path.lineTo(size.width - 15, 95);
    path.arcToPoint(Offset(size.width - 95, 15),
        radius: Radius.circular(10), largeArc: true);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class MapDisplay extends StatefulWidget {
  @override
  State<MapDisplay> createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(52.4, 5.2),
    zoom: 7.1,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}

class IncidentInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
        height: 200,
        child: Text('hello'));
  }
}
