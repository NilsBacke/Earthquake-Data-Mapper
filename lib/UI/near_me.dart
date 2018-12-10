import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:map_view/marker.dart';
import 'package:location/location.dart';
import 'package:earthquake_data_mapper/UI/colors.dart' as colors;

final Firestore db = Firestore.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class NearMe extends StatefulWidget {
  @override
  _NearMeState createState() => _NearMeState();
}

class _NearMeState extends State<NearMe> {
  List<Widget> earthquakeWidgets = new List();
  List<Earthquake> allDayEarthquakes = new List();
  EarthquakeData earthquakeData = new EarthquakeData();
  final _controller = TextEditingController();

  int range = 200; // miles

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    _firebaseMessaging.getToken().then((getToken) {
      var token = getToken;
      db.collection('locations').document(token).get().then((snapshot) {
        setState(() {
          if (snapshot.data['range'] != null) {
            range = snapshot.data['range'];
          } else {
            range = 100;
          }
        });
        getQuakes("all", "day").then((val) {
          allDayEarthquakes = earthquakeData.initEarthquakeData(val);
          _getEarthquakesNearMe(allDayEarthquakes).then((val2) {
            setState(() {
              earthquakeWidgets = val2;
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return new Card(
      color: colors.color,
      child: new GestureDetector(
        onLongPress: _showDialog,
        child: new ExpansionTile(
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    "Earthquakes Near Me",
                    style: new TextStyle(
                      fontSize: width <= 320 ? 12.0 : 14.0,
                      color: Colors.black,
                    ),
                  ),
                  new Text(
                    "Range: $range mi.",
                    style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              new PopupMenuButton(
                itemBuilder: (_) {
                  return [
                    new PopupMenuItem(
                      child: new InkWell(
                        onTap: _showDialog,
                        child: new Text('Change Range'),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          leading: new CircleAvatar(
            backgroundColor: Colors.red,
            child: new Text(
              '${earthquakeWidgets.length}',
              style: new TextStyle(color: Colors.white),
            ),
          ),
          children: earthquakeWidgets,
        ),
      ),
    );
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _getAlertDialog();
        }).then((value) {
      if (value != null) {
        print("value: $value");
        setState(() {
          range = int.parse(value);
          _saveRange();
          _getData();
        });
        print("range: $range");
      }
    });
  }

  _getAlertDialog() {
    print("get alert dialog");
    _controller.clear();
    return new AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              autofocus: true,
              controller: _controller,
              decoration:
                  new InputDecoration(labelText: 'Range', hintText: '100'),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: new Text("mi."),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        new FlatButton(
            child: const Text('CHANGE'),
            onPressed: () {
              print("Text: ${_controller.text}");
              Navigator.of(context).pop<String>(_controller.text);
            })
      ],
    );
  }

  Future<List<Widget>> _getEarthquakesNearMe(List<Earthquake> allDay) async {
    // a map of distances and earthquakes for sorting purposes
    List<Earthquake> earthquakesNearMe = new List<Earthquake>();
    List<double> distances = new List<double>();
    List<Widget> widgets = new List<Widget>();

    var currentLocation = <String, double>{};
    var location = new CurrentLocation();
    currentLocation = await location.getLocation();
    var homeLat = currentLocation['latitude'];
    var homeLon = currentLocation['longitude'];

    if (currentLocation == null) {
      return new List<Widget>();
    }

    for (int i = 0; i < allDay.length; i++) {
      double d = _getDistance(homeLat, homeLon, allDay[i].lat, allDay[i].long);
      if (d <= range) {
        earthquakesNearMe.add(allDay[i]);
        distances.add(d);
      }
    }

    // sort by distance
    earthquakesNearMe.sort((e1, e2) =>
        _getDistance(homeLat, homeLon, e1.lat, e1.long)
            .compareTo(_getDistance(homeLat, homeLon, e2.lat, e2.long)));

    distances.sort((d1, d2) => d1.compareTo(d2));

    for (var i = 0; i < earthquakesNearMe.length; i++) {
      widgets.add(_getEarthquakeWidget(earthquakesNearMe[i], distances[i]));
    }

    return widgets;
  }

  Widget _getEarthquakeWidget(Earthquake earthquake, double dist) {
    int roundedDist = dist.round();
    return new ListTile(
      leading: new CircleAvatar(
        child: new Text(
          '${earthquake.mag}',
          style: new TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      title: new Text('${earthquake.place}'),
      subtitle: new Text('${earthquake.time}'),
      trailing: new Text('$roundedDist mi.'),
      onTap: () {
        Marker marker;
        marker = new Marker("0", 'Mag: ${earthquake.mag} | ${earthquake.place}',
            earthquake.lat, earthquake.long);
        earthquakeData.showMapAtMarker(marker, allDayEarthquakes);
      },
    );
  }

  // in km
  double _getDistance(
      double homeLat, double homeLon, double earthLat, double earthLon) {
    const r = 6371;
    var dLat = _degToRad(earthLat - homeLat);
    var dLon = _degToRad(earthLon - homeLon);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(homeLat)) *
            cos(_degToRad(earthLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = r * c;
    d = d * 0.621371; // for miles
    return d;
  }

  double _degToRad(double degrees) => degrees * (pi / 180);

  void _saveRange() {
    _firebaseMessaging.getToken().then((getToken) {
      var token = getToken;
      db
          .collection('locations')
          .document(token)
          .setData({'range': range}, merge: true);
    });
  }
}
