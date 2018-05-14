import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;

var apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";

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

  _HomeState() {
    getQuakes().then((val) {
      setState(() {
        _data = val;
        _features = _data['features'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _mapView.show(_getMapOptions());
    _mapView.onMapReady.listen((_) {
      _setMarkers(_features);
      _mapView.zoomToFit(padding: 100);
    });
    return new Scaffold();
  }

  MapOptions _getMapOptions() {
    return new MapOptions(
      mapViewType: MapViewType.normal,
      showUserLocation: true,
      initialCameraPosition:
          new CameraPosition(new Location(45.5235258, -122.6732493), 14.0),
      title: "Earthquake Data Mapper",
    );
  }

  void _setMarkers(List list) async {
    for (int i = 0; i < list.length; i++) {
      _mapView.addMarker(new Marker(
          i.toString(),
          "Earthquake",
          list[i]['geometry']['coordinates'][0],
          list[i]['geometry']['coordinates'][1]));
      debugPrint("Latitude: ${list[i]['geometry']['coordinates'][0]}");
    }
  }
}

Future<Map> getQuakes() async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
