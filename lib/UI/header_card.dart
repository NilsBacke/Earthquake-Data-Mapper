import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:map_view/map_view.dart';

class HeaderCard extends StatefulWidget {
  @override
  _HeaderCardState createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List<Earthquake> allDayEarthquakes = new List();

  MapView mapView = new MapView();

  _HeaderCardState() {
    getQuakes("all", "day").then((val) {
      setState(() {
        allDayEarthquakes = earthquakeData.initEarthquakeData(val);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            allDayEarthquakes.length.toString(),
            textDirection: TextDirection.ltr,
            style: new TextStyle(
              fontSize: 75.0,
              fontWeight: FontWeight.w100,
              color: const Color(0xFF707070),
            ),
          ),
          new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text(
                  "Earthquakes today",
                  style: new TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w300),
                ),
                new ButtonTheme.bar(
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "View all",
                        ),
                        onPressed: () {
                          print("pressed");
                          setState(() {
                            earthquakeData.showMap(allDayEarthquakes);
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
