import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:earthquake_data_mapper/Model/api_info.dart' as apiInfo;
import 'package:earthquake_data_mapper/UI/colors.dart' as colors;
import 'package:auto_size_text/auto_size_text.dart';
import 'dots_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'maps.dart';
import 'package:earthquake_data_mapper/Model/static_maps.dart';

const static_maps_api_key = apiInfo.apiKey;

class MostSigList extends StatefulWidget {
  @override
  _MostSigListState createState() => _MostSigListState();
}

class _MostSigListState extends State<MostSigList> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List<Earthquake> sigWeekEarthquakes = new List();
  List<Earthquake> allDayEarthquakes = new List();

  final _controller = new PageController();

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    getQuakes("significant", "week").then((val) {
      var temp = earthquakeData.initEarthquakeData(val);
      temp.sort((e1, e2) => e2.mag.compareTo(e1.mag));
      setState(() {
        sigWeekEarthquakes = temp;
      });
    });
    getQuakes("all", "day").then((val) {
      setState(() {
        allDayEarthquakes = earthquakeData.initEarthquakeData(val);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sigWeekEarthquakes.length == 0) {
      return noSigCard();
    }
    return new Container(
      child: new Card(
        color: colors.color,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                child: new AutoSizeText(
                  "Most Significant Earthquakes This Week",
                  style: new TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
            new Divider(
              height: 4.0,
            ),
            new ConstrainedBox(
              constraints: new BoxConstraints.tightFor(
                height: 275,
              ),
              child: new PageView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemCount: sigWeekEarthquakes.length,
                itemBuilder: (_, i) {
                  return mostSigCard(i);
                },
              ),
            ),
            new Divider(
              height: 4.0,
            ),
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                child: new DotsIndicator(
                  color: Colors.grey,
                  controller: _controller,
                  itemCount: sigWeekEarthquakes.length,
                  onPageSelected: (int page) {
                    _controller.animateToPage(
                      page,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mostSigCard(int i) {
    // for significant earthquakes
    // id = 1000 + i
    // 1000, 1001
    Earthquake earth = sigWeekEarthquakes[i];
    Marker marker = new Marker(
        (1000 + i).toString(),
        new MarkerOptions(
            infoWindowText:
                new InfoWindowText('Mag: ${earth.mag} | ${earth.place}', null),
            position: new LatLng(earth.lat, earth.long)));

    return new Container(
      // width: 336.0,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width / 2 - 24.0,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "Magnitude: ${earth.mag}",
                        style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        earth.time.toString(),
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        earth.place,
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 4.0, left: 4.0, right: 8.0),
                  child: new Container(
                    child: new StaticMapsProvider(
                      static_maps_api_key,
                      marker: marker,
                    ),
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
                    "View on map",
                  ),
                  textColor: Colors.red,
                  onPressed: () {
                    List<MarkerOptions> markers = new List();
                    for (Earthquake e in allDayEarthquakes) {
                      markers.add(
                        new MarkerOptions(
                          visible: true,
                          position: new LatLng(e.lat, e.long),
                          infoWindowText: new InfoWindowText(
                              'Mag: ${e.mag} | ${e.place}', null),
                        ),
                      );
                    }
                    markers.add(
                      new MarkerOptions(
                        visible: true,
                        position: new LatLng(earth.lat, earth.long),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      ),
                    );
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => Maps(markers,
                            zoomTo: new LatLng(earth.lat, earth.long))));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget noSigCard() {
    return new Container(
      color: Colors.grey[300],
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
