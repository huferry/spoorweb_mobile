import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Overzicht extends StatelessWidget {
  final incidentInfo = IncidentInfo();

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
    incidentInfo._state.incident = incidents.last;
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
        right: 94,
        top: 16,
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

    path.moveTo(15, 15);
    path.lineTo(15, size.height - 15);
    path.lineTo(size.width - 15, size.height - 15);
    path.lineTo(size.width - 15, 60);
    path.arcToPoint(Offset(size.width - 102, 35),
        radius: Radius.circular(10), largeArc: true);
    path.lineTo(size.width - 202, 35);
    path.lineTo(size.width - 202, 15);
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

class IncidentInfo extends StatefulWidget {
  final _state = IncidentInfoState();

  void onUpdate(Map<String, dynamic> newIncient) {
    _state.onUpdate(newIncient);
  }

  @override
  State<StatefulWidget> createState() => _state;
}

class IncidentInfoState extends State<IncidentInfo> {
  Map<String, dynamic> incident = Map<String, dynamic>();

  void onUpdate(Map<String, dynamic> newIncident) {
    setState(() {
      incident = newIncident;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Color(0xFF737373),
            borderRadius: BorderRadius.circular(10.0)),
        height: 200,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [getIncidentId(), getTitle(), getDetail()]));
  }

  Widget getTitle() => Text(
        incident['title'] ?? '(incident)',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      );

  Widget getIncidentId() => Text(
        incident['incidentId']?.toString() ?? '(id)',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );

  Widget getDetail() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: getLeftColumn()),
            VerticalDivider(width: 1.0),
            Expanded(child: getRighColumn())
          ],
        ),
      );

  Widget getLeftColumn() => Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getLocalTimeField('tijd voorval', incident['datumTijdVoorval']),
            getField('melder', incident['melder']),
            getField(
                'treindienstleidergebied', incident['treindienstleidergebied']),
            getField('infraclaim', incident['infraclaim'])
          ],
        ),
      );

  Widget getRighColumn() => Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getLocalTimeField('prognose', incident['prognose']),
            getField('tis', incident['tis']),
            getField('slachtoffers', incident['slachtofers']),
            getField('impact', incident['impact'])
          ],
        ),
      );

  final fieldStyle =
      TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);

  final valueStyle = TextStyle(color: Color(0xFFCECECE), fontSize: 12);

  Widget getLocalTimeField(String name, String? value) {
    if (value == null) return getField(name, '');
    final format = DateFormat('kk:mm');
    return getField(name, format.format(DateTime.parse(value).toLocal()));
  }

  Widget getField(String name, String? value) => Container(
        margin: EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              name,
              style: fieldStyle,
            ),
            Text(
              value ?? '',
              style: valueStyle,
            )
          ],
        ),
      );
}
