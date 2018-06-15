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

  // final List<Widget> _pages = <Widget>[
  //   new ConstrainedBox(
  //     constraints: const BoxConstraints.expand(),
  //     child: new FlutterLogo(
  //         size: 100.0,
  //         style: FlutterLogoStyle.horizontal,
  //         colors: Colors.green),
  //   ),
  //   new ConstrainedBox(
  //     constraints: const BoxConstraints.expand(),
  //     child: new FlutterLogo(
  //         size: 100.0,
  //         style: FlutterLogoStyle.horizontal,
  //         colors: Colors.green),
  //   ),
  // ];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              headerCard(),
              horizontalCardList(),
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
    return new Container(
      height: 216.0,
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (BuildContext context, int i) {
          return mostSigCard();
        },
      ),
    );
  }

  Widget mostSigCard() {
    return new Container(
      width: 300.0,
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
                        "Magnitude 2.29",
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
                        child: new FittedBox(
                          fit: BoxFit.contain,
                          child: new Image.asset("images/cracks.jpg"),
                        )),
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
                      // setState(() {
                      //   earthquakeData.showMap();
                      // });
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
}
