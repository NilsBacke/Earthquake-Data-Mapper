import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:earthquake_data_mapper/Model/api_info.dart' as apiInfo;
import 'package:earthquake_data_mapper/UI/colors.dart' as colors;
import 'package:auto_size_text/auto_size_text.dart';
import 'dots_indicator.dart';

const static_maps_api_key = apiInfo.apiKey;

class MostSigList extends StatefulWidget {
  @override
  _MostSigListState createState() => _MostSigListState();
}

class _MostSigListState extends State<MostSigList> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List<Earthquake> sigWeekEarthquakes = new List();

  var provider = new StaticMapProvider(static_maps_api_key);
  Uri staticMapUri;

  final _controller = new PageController();

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final _kArrowColor = Colors.black.withOpacity(0.8);

  @override
  void initState() {
    super.initState();
    getQuakes("significant", "week").then((val) {
      setState(() {
        sigWeekEarthquakes = earthquakeData.initEarthquakeData(val);
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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new AutoSizeText(
                "Most Significant Earthquakes This Week",
                style: new TextStyle(fontSize: 18.0),
                textAlign: TextAlign.left,
                maxLines: 1,
              ),
            ),
            new Divider(
              height: 4.0,
            ),
            new Container(
              height: MediaQuery.of(context).size.height * .365,
              child: new PageView.builder(
                controller: _controller,
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
    Marker marker = new Marker(
        (1000 + i).toString(),
        'Mag: ${sigWeekEarthquakes[i].mag} | ${sigWeekEarthquakes[i].place}',
        sigWeekEarthquakes[i].lat,
        sigWeekEarthquakes[i].long);
    staticMapUri = provider.getStaticUriWithMarkers(
      [marker],
      center:
          new Location(sigWeekEarthquakes[i].lat, sigWeekEarthquakes[i].long),
      width: 500,
      height: 500,
    );

    return new Container(
      width: 336.0,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text(
                        "Magnitude: ${sigWeekEarthquakes[i].mag}",
                        style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
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
              ),
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Container(
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
                    "View on map",
                  ),
                  textColor: Colors.red,
                  onPressed: () {
                    setState(() {
                      earthquakeData.showMapAtMarker(marker);
                    });
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
