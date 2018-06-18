import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

const static_maps_api_key = "AIzaSyCEyNI6shSh4cpI3Ne6jQBxqTBGzBr4Kz0";

class MostSigList extends StatefulWidget {
  @override
  _MostSigListState createState() => _MostSigListState();
}

class _MostSigListState extends State<MostSigList> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List<Earthquake> sigWeekEarthquakes = new List();

  var provider = new StaticMapProvider(static_maps_api_key);
  Uri staticMapUri;

  @override
  void initState() {
    super.initState();
    staticMapUri =
        provider.getStaticUri(Locations.portland, 12, width: 400, height: 400);
    getQuakes("significant", "week").then((val) {
      sigWeekEarthquakes = earthquakeData.init(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sigWeekEarthquakes.length == 0) {
      return noSigCard();
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
                        sigWeekEarthquakes[i].time.toString(),
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        sigWeekEarthquakes[i].place,
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
                      child: new Image.network(staticMapUri.toString()),
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

  Widget noSigCard() {
    return new Container(
      height: 220.0,
      width: 400.0,
      child: new Card(
        child: new Center(
          child: new Text(
            "No Significant Earthquakes in the past week",
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
