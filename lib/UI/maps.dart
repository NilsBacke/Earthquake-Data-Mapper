import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Maps extends StatefulWidget {
  final List<MarkerOptions> markers;
  final LatLng zoomTo;

  Maps(this.markers, {this.zoomTo});

  @override
  _MapsState createState() => _MapsState(markers, zoomTo: this.zoomTo);
}

class _MapsState extends State<Maps> {
  GoogleMapController mapController;
  List<MarkerOptions> markers;
  LatLng pos;
  LatLng zoomTo;

  _MapsState(this.markers, {this.zoomTo});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Earthquake Data Mapper"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          options: GoogleMapOptions(
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    for (MarkerOptions m in markers) {
      controller.addMarker(m);
    }
    var currentLocation = <String, double>{};
    var location = new CurrentLocation();
    currentLocation = await location.getLocation();
    var homeLat = currentLocation['latitude'];
    var homeLon = currentLocation['longitude'];
    LatLng pos = new LatLng(homeLat, homeLon);
    double zoom = 0;

    if (currentLocation == null) {
      pos = new LatLng(34, -71);
    }

    if (zoomTo != null) {
      pos = zoomTo;
      zoom = 10;
    }

    controller.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
    setState(() {
      mapController = controller;
    });
  }
}
