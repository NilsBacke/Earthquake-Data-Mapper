import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaticMapsProvider extends StatefulWidget {
  final String googleMapsApiKey;
  final Marker marker;

  StaticMapsProvider(this.googleMapsApiKey, {this.marker});

  @override
  _StaticMapsProviderState createState() => new _StaticMapsProviderState();
}

class _StaticMapsProviderState extends State<StaticMapsProvider> {
  String renderURL;
  static const int defaultWidth = 800;
  static const int defaultHeight = 800;
  Map<String, String> defaultLocation = {
    "latitude": '37.0902',
    "longitude": '-95.7192'
  };

  _buildUrl() {
    String markerString =
        '${widget.marker.options.position.latitude},${widget.marker.options.position.longitude}';
    var baseUri = new Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'markers': markerString,
          'size': '${defaultWidth}x$defaultHeight',
          'center':
              '${widget.marker.options.position.latitude},${widget.marker.options.position.longitude}',
          'zoom': '6',
          'key': '${widget.googleMapsApiKey}'
        });

    setState(() {
      renderURL = baseUri.toString();
    });
  }

  Widget build(BuildContext context) {
    _buildUrl();
    return new Image.network(renderURL);
  }
}
