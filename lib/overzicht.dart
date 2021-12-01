import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Overzicht extends StatelessWidget {
  void onMarkerTap(Map<String, dynamic> incident) {
    print(incident['title']);
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

        return Stack(
            children: [buildBase(context, incidents), buildUser(context)]);
      },
    );
  }

  Widget buildBase(BuildContext context, List<Map<String, dynamic>> incidents) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: IncidentMap(incidents, onMarkerTap)),
        IncidentInfo()
      ],
    );
  }

  Widget buildUser(BuildContext context) {
    return Positioned(
        right: 12,
        top: 13,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(43),
          child: Image.network(
              'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/kaley-cuoco-1615625941.jpg',
              fit: BoxFit.cover,
              height: 86,
              width: 86),
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
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: markers,
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
            color: Color(0xFF737373),
            borderRadius: BorderRadius.circular(10.0)),
        height: 200,
        child: Text('hello'));
  }
}
