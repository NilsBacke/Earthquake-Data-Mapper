import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'data.dart';
import 'expansionTile.dart';
import 'package:http/http.dart' as http;

const apiKey = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";

void main() {
  MapView.setApiKey(apiKey);
  runApp(new Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List allHourEarthquakes = new List();
  List allDayEarthquakes = new List();
  List allWeekEarthquakes = new List();
  List sigHourEarthquakes = new List();
  List sigDayEarthquakes = new List();
  List sigWeekEarthquakes = new List();

  _HomeState() {
    getQuakes("all", "hour").then((val) {
      setState(() {
        allHourEarthquakes = earthquakeData.init(val);
      });
    });
    getQuakes("all", "day").then((val) {
      setState(() {
        allDayEarthquakes = earthquakeData.init(val);
      });
    });
    getQuakes("all", "week").then((val) {
      setState(() {
        allWeekEarthquakes = earthquakeData.init(val);
      });
    });
    getQuakes("significant", "hour").then((val) {
      setState(() {
        sigHourEarthquakes = earthquakeData.init(val);
      });
    });
    getQuakes("significant", "day").then((val) {
      setState(() {
        sigDayEarthquakes = earthquakeData.init(val);
      });
    });
    getQuakes("significant", "week").then((val) {
      setState(() {
        sigWeekEarthquakes = earthquakeData.init(val);
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
          centerTitle: true,
        ),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              headerCard(),
              horizontalCardList(), // uncomment, save, then recomment
              expansionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerCard() {
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
                            earthquakeData.showMap();
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

  Widget horizontalCardList() {
    if (sigWeekEarthquakes.length == 0) {
      return new Container(
        height: 220.0,
        width: 400.0,
        child: new Center(
          child: new Text("No Significant Earthquakes"),
        ),
        color: Colors.green,
      );
    }
    return new Container(
      height: 220.0,
      width: 400.0,
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sigWeekEarthquakes.length,
        itemBuilder: (BuildContext context, int i) {
          return mostSigCard(i);
        },
      ),
    );
  }

  Widget mostSigCard(int i) {
    return new Container(
      width: 340.0,
      height: 220.0,
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "Most Significant",
                        style: new TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "Magnitude ${sigWeekEarthquakes[i].mag}",
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "6/13/2018 9:25 PM",
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "4km SW of Volcano, Hawaii",
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Container(
                      color: Colors.green,
                      // child: new FittedBox(
                      //   fit: BoxFit.contain,
                      //   child: new Image.asset("images/cracks.jpg"),
                      // ),
                      child: new Image.asset("images/lava.jpg"),
                    ),
                  ),
                ),
              ],
            ),
            new ButtonTheme.bar(
              child: ButtonBar(
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "View",
                    ),
                    onPressed: () {
                      print("pressed");
                      setState(() {
                        earthquakeData.showMap();
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget expansionList() {
    return new Expanded(
      // height: 300.0,
      // margin: new EdgeInsets.all(20.0),
      child: new Card(
        child: new ListView.builder(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int i) {
            return new EntryItem(data[i]);
          },
          itemCount: data.length,
        ),
      ),
    );
  }
}

Future<Map> getQuakes(String apiType, String apiRange) async {
  String apiURLquake =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/${apiType}_${apiRange}.geojson";
  http.Response response = await http.get(apiURLquake);
  return json.decode(response.body);
}
