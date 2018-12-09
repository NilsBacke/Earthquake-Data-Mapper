import 'dart:async';
import 'dart:convert';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'earthquake.dart';

class EarthquakeData {
  var _mapView = new MapView();

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

  showMap(List<Earthquake> list) {
    _mapView = new MapView();
    _mapView
        .show(_getMapOptions(), toolbarActions: [new ToolbarAction("Back", 0)]);
    List<Marker> markers = getMarkers(list);
    _mapView.onMapReady.listen((_) {
      _mapView.setMarkers(markers);
      _mapView.zoomToFit(padding: 100);
    });
    _setToolbarAction();
  }

  showMapAtMarker(Marker marker, List<Earthquake> list) {
    _mapView = new MapView();
    _mapView.show(_getMapOptionsFromMarker(marker),
        toolbarActions: [new ToolbarAction("Back", 0)]);
    List<Marker> markers = getMarkers(list);
    markers.add(marker);
    _mapView.onMapReady.listen((_) {
      _mapView.setMarkers(markers);
      // _mapView.z([marker.id]);
    });
    _setToolbarAction();
  }

  List<Marker> getMarkers(List<Earthquake> list) {
    List<Marker> markers = new List();
    print("List length: ${list.length}");
    for (int i = 0; i < list.length; i++) {
      markers.add(new Marker(i.toString(),
          'Mag: ${list[i].mag} | ${list[i].place}', list[i].lat, list[i].long));
    }
    return markers;
  }

  MapOptions _getMapOptionsFromMarker(Marker marker) {
    return new MapOptions(
      mapViewType: MapViewType.normal,
      initialCameraPosition: new CameraPosition(
          new Location(marker.latitude, marker.longitude), 6.0),
      showUserLocation: true,
      title: "Earthquake Data Mapper",
    );
  }

  MapOptions _getMapOptions() {
    return new MapOptions(
      mapViewType: MapViewType.normal,
      showUserLocation: true,
      title: "Earthquake Data Mapper",
    );
  }

  _setToolbarAction() {
    _mapView.onToolbarAction.listen((id) {
      if (id == 0) {
        _mapView.dismiss();
      }
    });
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
