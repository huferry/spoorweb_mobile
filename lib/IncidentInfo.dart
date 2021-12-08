import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'incidentView.dart';

class IncidentInfo extends StatefulWidget {
  final state = IncidentInfoState();
  bool showFullSreen = false;

  IncidentInfo({String incidentId = "", bool showFullscreen = false}) {
    if (incidentId != "") {
      state.incidentId = incidentId;
    }

    this.showFullSreen = showFullscreen;
  }

  void onUpdate(String incidentId) {
    state.onUpdate(incidentId);
  }

  @override
  State<StatefulWidget> createState() => state;
}

class IncidentInfoState extends State<IncidentInfo> {
  String incidentId = "";
  Map<String, dynamic> incident = Map<String, dynamic>();

  void onUpdate(String newIncidentId) {
    setState(() {
      incidentId = newIncidentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> _incidentStream = FirebaseFirestore.instance
        .collection('incidents')
        .doc(incidentId)
        .snapshots();

    return incidentId == ""
        ? Text("")
        : StreamBuilder<DocumentSnapshot>(
            stream: _incidentStream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              }

              incident = snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                  margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Color(0xFF737373),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [getTitleBar(context), getDetail()]));
            });
  }

  Widget getTitleBar(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [getIncidentId(), getTitle()],
            ),
          ),
          incident.isEmpty
              ? Text("")
              : (widget.showFullSreen
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return IncidentView(incident);
                        }));
                      },
                      child: Icon(Icons.fullscreen_outlined,
                          color: Colors.white, size: 40))
                  : GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.map, color: Colors.white, size: 40),
                    ))
        ],
      );

  Widget getTitle() => Text(
        incident['title'] ?? '(incident)',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.visible),
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
            VerticalDivider(width: 4.0),
            Expanded(child: getRighColumn())
          ],
        ),
      );

  Widget getLeftColumn() => Container(
        margin: EdgeInsets.only(top: 5, left: 5),
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
        margin: EdgeInsets.only(top: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getLocalTimeField('prognose', incident['prognose']),
            getField('tis', incident['tis']),
            getField('slachtoffers', incident['slachtoffers']),
            getField('impact', incident['impact'])
          ],
        ),
      );

  final fieldStyle =
      TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

  final valueStyle = TextStyle(color: Color(0xFFCECECE), fontSize: 14);

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
