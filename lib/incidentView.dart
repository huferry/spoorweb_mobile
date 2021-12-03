import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:spoorweb_mobile/IncidentInfo.dart';

class IncidentView extends StatelessWidget {
  final Map<String, dynamic> incident;
  final IncidentInfo _incidentInfo = IncidentInfo();

  IncidentView(this.incident);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF383838),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getMap(),
              IncidentInfo(incident: incident),
              LogList(incident['incidentId'])
            ],
          ),
        ),
      );

  Widget getMap() {
    print(incident['longitude']);
    var lat = incident['latitude'];
    var lon = incident['longitude'];

    final incidentPosition = CameraPosition(
      target: LatLng(double.parse(lat), double.parse(lon)),
      zoom: 12,
    );

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(15),
      height: 150,
      child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: incidentPosition,
          zoomControlsEnabled: false,
          markers: [
            Marker(
                markerId: MarkerId('incident'),
                position: incidentPosition.target)
          ].toSet()),
    );
  }
}

class LogList extends StatelessWidget {
  final int incidentId;

  LogList(int this.incidentId);

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _incidentStream = FirebaseFirestore.instance
        .collection('logs')
        .where('incidentId', isEqualTo: incidentId)
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

        var logs = snapshot.data!.docs.map((DocumentSnapshot document) {
          return document.data()! as Map<String, dynamic>;
        }).toList();

        return getList(logs);
      },
    );
  }

  Widget getList(List<Map<String, dynamic>> logs) {
    final logWidgets = logs.map(getLogWidget).toList().reversed.toList();

    logWidgets.insert(
        0,
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 10),
          child: Text(
            'Logboek',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ));

    return Expanded(
      child: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Color(0xFF737373),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: logWidgets,
              ))),
    );
  }

  Widget getLogWidget(Map<String, dynamic> log) {
    final style = TextStyle(color: Colors.white);

    final time = DateFormat('kk:mm')
        .format(DateTime.parse(log['creationTime']).toLocal());

    final timeWidget = Container(
        margin: EdgeInsets.only(right: 4, bottom: 2),
        child: Text(time, style: style));

    final contentWidget = Expanded(
        child: Container(
            child: Text(
      log['content'],
      style: style,
      overflow: TextOverflow.visible,
    )));

    return Container(
        margin: EdgeInsets.only(bottom: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [timeWidget, contentWidget],
        ));
  }
}
