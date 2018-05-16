import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

var apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";
String _apiRange = "day";
String _apiType = "all";

void main() {
  MapView.setApiKey(apiKey);
  runApp(new Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  var _mapView = new MapView();
  TabController _tabController;

  Map _data = new Map();
  List _features = new List();

  int radioValue = 1;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    getQuakes().then((val) {
      setState(() {
        _data = val;
        _features = _data['features'];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRadioValueChanged(int value) {
    setState(() {
      radioValue = value;
    });
    switch (radioValue) {
      case 0:
        _apiRange = "hour";
        break;
      case 1:
        _apiRange = "day";
        break;
      case 2:
        _apiRange = "week";
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

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _apiType = "all";
          break;
        case 1:
          _apiType = "significant";
          break;
        default:
      }
    });
    getQuakes().then((val) {
      setState(() {
        _data = val;
        _features = _data['features'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Earthquake Data Mapper",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Earthquake Data Mapper"),
          backgroundColor: Colors.blue,
          centerTitle: true,
          bottom: new TabBar(
            controller: _tabController,
            tabs: <Widget>[
              new Tab(
                text: "All Earthquakes",
              ),
              new Tab(
                text: "Significant Earthquakes",
              ),
            ],
          ),
        ),
        body: new TabBarView(
          children: <Widget>[
            getTabView(),
            getTabView(),
          ],
          controller: _tabController,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget getTabView() {
    return new Container(
      // padding: new EdgeInsets.only(top: 30.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(2.0),
          ),
          new Row(
            children: <Widget>[
              new Radio<int>(
                value: 0,
                groupValue: radioValue,
                onChanged: _handleRadioValueChanged,
                activeColor: Colors.white,
              ),
              new Text("Past Hour"),
              new Radio<int>(
                value: 1,
                groupValue: radioValue,
                onChanged: _handleRadioValueChanged,
                activeColor: Colors.white,
              ),
              new Text("Past Day"),
              new Radio<int>(
                value: 2,
                groupValue: radioValue,
                onChanged: _handleRadioValueChanged,
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
            child: new ListView.builder(
                itemCount: _features.length,
                itemBuilder: (_, index) {
                  return quakeCard(_, index);
                }),
          ),
        ],
      ),
    );
  }

  Card quakeCard(BuildContext context, int i) {
    if (_features == null || _features.isEmpty || _features.length == 0) {
      return new Card(
        color: Colors.white,
        child:
            new Text("There is no earthquake data for the specified criteria"),
      );
    }
    var mag = _features[i]['properties']['mag'];
    return new Card(
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Color.fromRGBO(255, 0, 0, mag / 10),
              child: new Text(
                mag.toString(),
                style: new TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            title: new Text("Magnitude: ${mag.toString()}"),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text(_getTime(i)),
                new Text(_features[i]['properties']['place'].toString()),
              ],
            ),
          ),
        ],
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

  String _getTime(int index) {
    int milliseconds =
        (int.parse(_features[index]['properties']['time'].toString()));
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    var format = new DateFormat.yMd().add_jm();
    return format.format(date);
  }
}

Future<Map> getQuakes() async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/${_apiType}_$_apiRange.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
