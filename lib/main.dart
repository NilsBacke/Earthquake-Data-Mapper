import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;

var apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";
String _apiType = "all_day";

void main() {
  MapView.setApiKey(apiKey);
  runApp(new MaterialApp(
    title: "Earthquake Data Mapper",
    home: new Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  var _mapView = new MapView();

  Map _data = new Map();
  List _features = new List();

  int radioValue = 0;

  _HomeState() {
    getQuakes().then((val) {
      setState(() {
        _data = val;
        _features = _data['features'];
      });
    });
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
    switch (radioValue) {
      case 0:
        _apiType = "all_hour";
        break;
      case 1:
        _apiType = "all_day";
        break;
      case 2:
        _apiType = "all_week";
        break;
      default:
    }
    getQuakes().then((val) {
      setState(() {
        _data = val;
        _features = _data['features'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Earthquake Data Mapper"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: new Container(
        // padding: new EdgeInsets.only(top: 30.0),
        
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(2.0),
            ),
            new Row(
              children: <Widget>[
                new Radio<int>(
                  value: 0,
                  groupValue: radioValue,
                  onChanged: handleRadioValueChanged,
                  activeColor: Colors.white,
                ),
                new Text("Past Hour"),
                new Radio<int>(
                  value: 1,
                  groupValue: radioValue,
                  onChanged: handleRadioValueChanged,
                  activeColor: Colors.white,
                ),
                new Text("Past Day"),
                new Radio<int>(
                  value: 2,
                  groupValue: radioValue,
                  onChanged: handleRadioValueChanged,
                  activeColor: Colors.white,
                ),
                new Text("Past Week"),
              ],
            ),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
              child: new Text("Show Map"),
              onPressed: showMap,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new Flexible(
              child: new ListView.builder(itemBuilder: (_, index) {
                return quakeCard(_, index);
              }),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue,
    );
  }

  Card quakeCard(BuildContext context, int i) {
    if (_features.length != 0) {
      var mag = _features[i]['properties']['mag'];
      return new Card(
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: new Opacity(
                opacity: mag / 10,
                child: new CircleAvatar(
                  backgroundColor: Colors.red[900],
                  child: new Text(
                    mag.toString(),
                    style: new TextStyle(color: Colors.black),
                  ),
                ),
              ),
              title: new Text("Magnitude: ${mag.toString()}"),
              subtitle: new Text(_features[i]['properties']['place']),
            ),
          ],
        ),
      );
    } else {
      return new Card();
    }
  }

  void showMap() {
    _mapView.show(_getMapOptions(),
        toolbarActions: [new ToolbarAction("Refresh", 1)]);
    _mapView.onMapReady.listen((_) {
      _setMarkers(_features);
      _mapView.zoomToFit(padding: 1000);
    });
  }

  MapOptions _getMapOptions() {
    return new MapOptions(
      mapViewType: MapViewType.normal,
      showUserLocation: true,
      initialCameraPosition:
          new CameraPosition(new Location(45.5235258, -122.6732493), 1.0),
      title: "Earthquake Data Mapper",
    );
  }

  void _setMarkers(List list) {
    for (int i = 0; i < list.length; i++) {
      setState(() {
        _mapView.addMarker(new Marker(
            i.toString(),
            "Mag: ${list[i]['properties']['mag']} | ${list[i]['properties']['place']}",
            list[i]['geometry']['coordinates'][1],
            list[i]['geometry']['coordinates'][0]));
      });
    }
  }
}

Future<Map> getQuakes() async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/$_apiType.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
