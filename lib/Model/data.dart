import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'earthquake.dart';

class EarthquakeData {
  Map _data = new Map();
  List _features = new List();

  List initEarthquakeData(val) {
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
}

Future<Map> getQuakes(String apiType, String apiRange) async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/${apiType}_${apiRange}.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
