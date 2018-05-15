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
        padding: new EdgeInsets.only(top: 30.0),
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
                ),
                new Text("Past Hour"),
                new Radio<int>(
                    value: 1,
                    groupValue: radioValue,
                    onChanged: handleRadioValueChanged),
                new Text("Past Day"),
                new Radio<int>(
                    value: 2,
                    groupValue: radioValue,
                    onChanged: handleRadioValueChanged),
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
          ],
        ),
      ),
    );
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
          new CameraPosition(new Location(45.5235258, -122.6732493), 14.0),
      title: "Earthquake Data Mapper",
    );
  }

  void _setMarkers(List list) {
    for (int i = 0; i < list.length; i++) {
      setState(() {
        _mapView.addMarker(new Marker(
            i.toString(),
            list[i]['properties']['place'],
            list[i]['geometry']['coordinates'][0],
            list[i]['geometry']['coordinates'][1]));
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
