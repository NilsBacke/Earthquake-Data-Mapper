import 'dart:async';
import 'dart:convert';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'earthquake.dart';
import 'package:flutter/material.dart';

const apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";

class EarthquakeData {
  EarthquakeData();

  var _mapView = new MapView();

  Map _data = new Map();
  List _features = new List();

  List initEarthquakeData(val) {
    MapView.setApiKey(apiKey);
    List<Earthquake> earthquakes = new List();
    _data = val;
    _features = _data['features'];
    for (int i = 0; i < _features.length; i++) {
      var e = _features[i]['properties'];
      var g = _features[i]['geometry']['coordinates'];
      earthquakes.add(
        new Earthquake(
          mag: e['mag'],
          place: e['place'],
          time: e['time'],
          url: e['url'],
          lat: g[1],
          long: g[0],
        ),
      );
    }
    return earthquakes;
  }

  void showMap(List<Earthquake> earthquakes) {
    _mapView.show(_getMapOptions(),
        toolbarActions: [new ToolbarAction("Refresh", 1)]);
    _mapView.onMapReady.listen((_) {
      // _mapView.setMarkers(_getMarkers(earthquakes));
      _setMarkers(_features);
      _mapView.zoomToFit(padding: 100);
      debugPrint(
          "****************************************************************ready2");
    });
  }

  void showMapAtMarker(Marker marker) {
    _mapView.show(_getMapOptions(),
        toolbarActions: [new ToolbarAction("Refresh", 1)]);
    List<Marker> markers = new List();
    markers.add(marker);
    _mapView.onMapReady.listen((_) {
      // _mapView.setMarkers([marker]);
      _setMarkers(_features);
      _mapView.zoomToFit(padding: 50);
      debugPrint("ready");
    });
  }

  List<Marker> _getMarkers(List<Earthquake> list) {
    List<Marker> markers = new List();
    for (int i = 0; i < list.length; i++) {
      markers.add(new Marker(
          i.toString(), '${list[i].place}', list[i].lat, list[i].long));
    }
    return markers;
  }

  void _setMarkers(List list) {
    for (int i = 0; i < list.length; i++) {
      // setState(() {
      _mapView.addMarker(new Marker(
          i.toString(),
          "Mag: ${list[i]['properties']['mag']} | ${list[i]['properties']['place']}",
          list[i]['geometry']['coordinates'][1],
          list[i]['geometry']['coordinates'][0]));
      // });
    }
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

  getMapView() {
    return _mapView;
  }
}

Future<Map> getQuakes(String apiType, String apiRange) async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/${apiType}_${apiRange}.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
