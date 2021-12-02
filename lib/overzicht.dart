import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'IncidentInfo.dart';

class Overzicht extends StatelessWidget {
  final incidentInfo = IncidentInfo(showFullscreen: true);

  void onMarkerTap(Map<String, dynamic> incident) {
    incidentInfo.onUpdate(incident);
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _incidentStream = FirebaseFirestore.instance
        .collection('incidents')
        .where('processStatus', isNotEqualTo: 'Open')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _incidentStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('loading');
        }

        if (snapshot.data != null) {
          print(snapshot.data?.size);
        }

        var incidents = snapshot.data!.docs.map((DocumentSnapshot document) {
          return document.data()! as Map<String, dynamic>;
        }).toList();

        return Stack(children: [
          buildBase(context, incidents),
          buildUser(context),
          buildUserName(context)
        ]);
      },
    );
  }

  Widget buildBase(BuildContext context, List<Map<String, dynamic>> incidents) {
    incidentInfo.state.incident = incidents.last;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: IncidentMap(incidents, onMarkerTap)),
        incidentInfo
      ],
    );
  }

  Widget buildUser(BuildContext context) {
    return Positioned(
        right: 30,
        top: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.network(
              'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/kaley-cuoco-1615625941.jpg',
              fit: BoxFit.cover,
              height: 60,
              width: 60),
        ));
  }

  Widget buildUserName(BuildContext context) {
    return Positioned(
        right: 92,
        top: 14,
        child: Text(
          'Kaley (MKS BO)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 8.0,
                color: Color.fromARGB(255, 0, 0, 0),
              )
            ],
          ),
        ));
  }
}

class IncidentMap extends StatelessWidget {
  final List<Map<String, dynamic>> incidents;
  final void Function(Map<String, dynamic>) onMarkerTab;

  IncidentMap(this.incidents, this.onMarkerTab);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: MapDisplay(this.incidents, this.onMarkerTab)),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(20, 15);
    path.lineTo(15, 20);
    path.lineTo(15, size.height - 20);
    path.lineTo(20, size.height - 15);
    path.lineTo(size.width - 20, size.height - 15);
    path.lineTo(size.width - 15, size.height - 20);
    path.lineTo(size.width - 15, 60);
    path.arcToPoint(Offset(size.width - 105, 40),
        radius: Radius.circular(10), largeArc: true);
    path.lineTo(size.width - 115, 35);
    path.lineTo(size.width - 185, 35);

    path.arcToPoint(Offset(size.width - 205, 18),
        radius: Radius.circular(18), largeArc: false);
    path.lineTo(size.width - 208, 15);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class MapDisplay extends StatefulWidget {
  final List<Map<String, dynamic>> incidents;
  final void Function(Map<String, dynamic>) onMarkerTab;

  MapDisplay(this.incidents, this.onMarkerTab);

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
    final markers = widget.incidents
        .map((i) => Marker(
            infoWindow: InfoWindow(title: i['title']),
            onTap: () => widget.onMarkerTab(i),
            markerId: MarkerId(i['incidentId'].toString()),
            position: LatLng(
                double.parse(i['latitude']), double.parse(i['longitude']))))
        .toSet();

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
