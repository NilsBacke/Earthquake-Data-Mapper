import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:map_view/map_view.dart';
import 'package:earthquake_data_mapper/UI/colors.dart' as colors;
import 'package:auto_size_text/auto_size_text.dart';

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
      color: colors.color,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Container(
            width: MediaQuery.of(context).size.width / 10 * 3.75,
            child: new AutoSizeText(
              allDayEarthquakes.length.toString(),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 75.0,
                fontWeight: FontWeight.w100,
                color: Colors.red[600],
              ),
              maxLines: 1,
            ),
          ),
          new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: new AutoSizeText(
                    "Earthquakes today",
                    style: new TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w400),
                    maxLines: 1,
                  ),
                ),
                new ButtonTheme.bar(
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "View all",
                        ),
                        textColor: Colors.red,
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
