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
    print("init");
    _getData();
    _getRange();
  }

  _getData() async {
    getQuakes("all", "day").then((val) {
      allDayEarthquakes = earthquakeData.initEarthquakeData(val);
      _getEarthquakesNearMe(allDayEarthquakes).then((val2) {
        setState(() {
          earthquakeWidgets = val2;
          debugPrint(earthquakeWidgets.length.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return new Card(
      // color: Colors.lightBlue[200],
      color: colors.color,
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
                    child: new GestureDetector(
                      child: Container(
                        child: new Text('Change Range'),
                      ),
                      onTap: () {
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
                      },
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
    );
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
                  new InputDecoration(labelText: 'Range', hintText: 'eg. 100'),
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
    List<Widget> widgets = new List<Widget>();

    var currentLocation = <String, double>{};

    var location = new CurrentLocation();

    currentLocation = await location.getLocation();

    if (currentLocation == null) {
      return new List<Widget>();
    }

    for (int i = 0; i < allDay.length; i++) {
      double d = _getDistance(currentLocation['latitude'],
          currentLocation['longitude'], allDay[i].lat, allDay[i].long);
      debugPrint('dist: $d');
      if (d <= range) {
        debugPrint("add widget");
        widgets.add(_getEarthquakeWidget(allDay[i]));
      }
    }

    return widgets;
  }

  Widget _getEarthquakeWidget(Earthquake earthquake) {
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
      onTap: () {
        print("tap");
        Marker marker;
        marker = new Marker("0", 'Mag: ${earthquake.mag} | ${earthquake.place}',
            earthquake.lat, earthquake.long);
        earthquakeData.showMapAtMarker(marker);
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

  void _getRange() {
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
      });
    });
  }
}
