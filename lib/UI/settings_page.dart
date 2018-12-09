import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore db = Firestore.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var token;
  var _dist;
  var _minMag;
  Widget hint1, hint2;

  _SettingsPageState() {
    _firebaseMessaging.getToken().then((getToken) async {
      token = getToken;
      var dist = await getDistance();
      setState(() {
        _dist = dist;
      });
      hint1 = new Text(_dist.toString());

      var minMag = await getMinMag();
      setState(() {
        _minMag = minMag;
      });
      hint2 = new Text(_minMag.toString());
    });
  }

  void saveDistance(int dist) async {
    setState(() {
      _dist = dist;
    });
    db
        .collection('locations')
        .document(token)
        .setData({'maxDist': dist}, merge: true);
  }

  Future<int> getDistance() async {
    var doc = await db.collection('locations').document(token).get();
    return doc.data['maxDist'];
  }

  void saveMinMag(int minMag) async {
    setState(() {
      _minMag = minMag;
    });
    db
        .collection('locations')
        .document(token)
        .setData({'minMag': minMag}, merge: true);
  }

  Future<int> getMinMag() async {
    var doc = await db.collection('locations').document(token).get();
    return doc.data['minMag'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: new Container(
        padding: const EdgeInsets.only(top: 8.0),
        child: new ListView(
          children: <Widget>[
            maxRadius(),
            minMagnitude(),
          ],
        ),
      ),
    );
  }

  Widget maxRadius() {
    return new ListTile(
      title: new Text("Notifications"),
      subtitle:
          new Text("Maximum radius for earthquake notifications in miles"),
      trailing: new DropdownButton<int>(
        key: new Key("1"),
        onChanged: saveDistance,
        hint: hint1,
        value: _dist,
        items: <DropdownMenuItem<int>>[
          menuItem(10),
          menuItem(50),
          menuItem(100),
          menuItem(250),
          menuItem(500),
          menuItem(1000),
          menuItem(2000),
          menuItem(5000),
        ],
      ),
    );
  }

  Widget minMagnitude() {
    return new ListTile(
      title: new Text("Notifications"),
      subtitle: new Text("Minimum magnitude for earthquake notifications"),
      trailing: new DropdownButton<int>(
        key: new Key("2"),
        onChanged: saveMinMag,
        value: _minMag,
        hint: hint2,
        items: <DropdownMenuItem<int>>[
          menuItem(1),
          menuItem(2),
          menuItem(3),
          menuItem(4),
          menuItem(5),
          menuItem(6),
          menuItem(7),
          menuItem(8),
          menuItem(9),
        ],
      ),
    );
  }

  DropdownMenuItem<int> menuItem(int value) {
    return new DropdownMenuItem<int>(
      value: value,
      child: Text(value.toString()),
    );
  }
}
