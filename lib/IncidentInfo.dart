import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spoorweb_mobile/incidentView.dart';

class IncidentInfo extends StatefulWidget {
  final state = IncidentInfoState();
  bool showFullSreen = false;

  IncidentInfo({Map<String, dynamic>? incident, bool showFullscreen = false}) {
    if (incident != null) {
      state.incident = incident;
    }

    this.showFullSreen = showFullscreen;
  }

  void onUpdate(Map<String, dynamic> newIncient) {
    state.onUpdate(newIncient);
  }

  @override
  State<StatefulWidget> createState() => state;
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [getTitleBar(context), getDetail()]));
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
          widget.showFullSreen
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return IncidentView(incident);
                    }));
                  },
                  child: Icon(Icons.fullscreen_outlined,
                      color: Colors.white, size: 40))
              : Text('')
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
