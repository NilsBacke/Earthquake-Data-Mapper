import 'dart:async';
import 'dart:convert';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'earthquake.dart';

const apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";

class EarthquakeData {
  EarthquakeData();

  var _mapView = new MapView();

  Map _data = new Map();
  List _features = new List();

  List init(val) {
    List<Earthquake> earthquakes = new List();
    _data = val;
    _features = _data['features'];
    for (int i = 0; i < _features.length; i++) {
      var e = _features[i]['properties'];
      earthquakes.add(new Earthquake(
          mag: e['mag'], place: e['place'], time: e['time'], url: e['url']));
    }
    return earthquakes;
  }

  void showMap() {
    _mapView.show(_getMapOptions(),
        toolbarActions: [new ToolbarAction("Refresh", 1)]);
    _mapView.onMapReady.listen((_) {
      _setMarkers(_features);
      _mapView.zoomToFit(padding: 1000);
    });
  }

  void showMapAtMarker(String id) {
    _mapView.show(_getMapOptions());
    _mapView.onMapReady.listen((_) {
      _setMarkers(_features);
      _mapView.zoomTo([id]);
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
      // setState(() {
      _mapView.addMarker(new Marker(
          i.toString(),
          "Mag: ${list[i]['properties']['mag']} | ${list[i]['properties']['place']}",
          list[i]['geometry']['coordinates'][1],
          list[i]['geometry']['coordinates'][0]));
      // });
    }
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
