import 'dart:async';

import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:location/location.dart';
import 'package:map_view/marker.dart';

int range = 3500;

enum ChangeRange { changeRange }

class NearMe extends StatefulWidget {
  @override
  _NearMeState createState() => _NearMeState();
}

class _NearMeState extends State<NearMe> with SingleTickerProviderStateMixin {
  List<Widget> earthquakeWidgets = new List();
  List<Earthquake> allDayEarthquakes = new List();
  EarthquakeData earthquakeData = new EarthquakeData();
  @override
  void initState() {
    super.initState();
    getQuakes("all", "day").then((val) {
      allDayEarthquakes = earthquakeData.initEarthquakeData(val);
      _getEarthquakesNearMe(allDayEarthquakes).then((val2) {
        setState(() {
          earthquakeWidgets = val2;
          debugPrint(earthquakeWidgets.length.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      // child: new ListView.builder(
      //   shrinkWrap: true,
      //   physics: ClampingScrollPhysics(),
      //   itemCount: earthquakeWidgets.length,
      //   itemBuilder: (_, index) {
      //     return new ExpansionTile(
      //       title: new Text("Earthquakes Near Me"),
      //       leading: new CircleAvatar(
      //         child: new GestureDetector(
      //           onTap: () => debugPrint("pressed"),
      //           child: new Text("$range mi."),
      //         ),
      //       ),
      //       children: earthquakeWidgets,
      //     );
      //   },
      // ),
      child: new ExpansionTile(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text("Earthquakes Near Me"),
            new PopupMenuButton(
              itemBuilder: (_) {
                return [
                  new PopupMenuItem(
                    child: new Text('Change Range'),
                  )
                ];
              },
            ),
          ],
        ),
        leading: new CircleAvatar(
          backgroundColor: Colors.red,
          child: new GestureDetector(
            onTap: () => debugPrint("pressed"),
            child: new Text('${earthquakeWidgets.length}'),
          ),
        ),
        children: earthquakeWidgets,
      ),
    );
  }

  Future<List<Widget>> _getEarthquakesNearMe(List<Earthquake> allDay) async {
    List<Widget> widgets = new List();
    var currentLocation = <String, double>{};
    var location = new Location();

    try {
      currentLocation = await location.getLocation;
      debugPrint("Location: ${currentLocation['latitude']}");
    } catch (e) {
      currentLocation = null;
      debugPrint("error");
    }
    debugPrint('length: ${allDay.length}');
    for (int i = 0; i < allDay.length; i++) {
      double d = _getDistance(currentLocation['latitude'],
          currentLocation['longitude'], allDay[i].lat, allDay[i].long);
      debugPrint('dist: $d');
      if (d <= range) {
        debugPrint("add widget");
        widgets.add(_getEarthquakeWidget(allDay[i]));
      }
    }

    return widgets;
  }

  Widget _getEarthquakeWidget(Earthquake earthquake) {
    return new ListTile(
      leading: new CircleAvatar(
        child: new Text('${earthquake.mag}'),
      ),
      title: new Text('${earthquake.place}'),
      subtitle: new Text('${earthquake.time}'),
      onTap: () {
        print("tap");
        Marker marker;
        marker = new Marker("0", 'Mag: ${earthquake.mag} | ${earthquake.place}',
            earthquake.lat, earthquake.long);
        earthquakeData.showMapAtMarker(marker);
      },
    );
  }

  // in km
  double _getDistance(
      double homeLat, double homeLon, double earthLat, double earthLon) {
    const r = 6371;
    var dLat = _degToRad(earthLat - homeLat);
    var dLon = _degToRad(earthLon - homeLon);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(homeLat)) *
            cos(_degToRad(earthLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = r * c;
    return d;
  }

  double _degToRad(double degrees) => degrees * (pi / 180);
}
