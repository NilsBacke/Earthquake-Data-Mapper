import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'data.dart';

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

  @override
  void initState() {
    super.initState();
    setState(() {
      earthquakeData.init("all", "day");
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
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              headerCard(),
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
            "547",
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(
                  child: new Text(
                    "Earthquakes today",
                    style: new TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w300),
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
}
