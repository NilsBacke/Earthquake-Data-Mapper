import 'package:earthquake_data_mapper/Model/data.dart';
import 'package:earthquake_data_mapper/Model/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:earthquake_data_mapper/UI/colors.dart' as colors;

class ExpansionList extends StatefulWidget {
  @override
  _ExpansionListState createState() => _ExpansionListState();
}

class _ExpansionListState extends State<ExpansionList> {
  EarthquakeData earthquakeData = new EarthquakeData();
  List<Entry> expansionData = new List();
  List<Earthquake> allHourEarthquakes = new List();
  List<Earthquake> allDayEarthquakes = new List();
  List<Earthquake> allWeekEarthquakes = new List();

  _ExpansionListState() {
    if (expansionData.isEmpty &&
        allHourEarthquakes.isEmpty &&
        allDayEarthquakes.isEmpty &&
        allWeekEarthquakes.isEmpty) {
      getQuakes("all", "hour").then((val1) {
        getQuakes("all", "day").then((val2) {
          getQuakes("all", "week").then((val3) {
            setState(() {
              allHourEarthquakes = earthquakeData.initEarthquakeData(val1);
              allDayEarthquakes = earthquakeData.initEarthquakeData(val2);
              allWeekEarthquakes = earthquakeData.initEarthquakeData(val3);
              expansionData = getExpansionData(
                  allHourEarthquakes, allDayEarthquakes, allWeekEarthquakes);
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      // height: 300.0,
      // margin: new EdgeInsets.all(20.0),
      child: new Card(
        color: colors.color,
        // color: Colors.lightBlue[200],
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(8.0),
              child: new Text(
                "All Earthquakes",
                style: new TextStyle(fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
            new Divider(),
            new ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                return new EntryItem(
                    expansionData[i],
                    allHourEarthquakes,
                    allDayEarthquakes,
                    allWeekEarthquakes,
                    new EarthquakeData());
              },
              itemCount: expansionData.length,
              physics: ClampingScrollPhysics(),
            ),
          ],
        ),
      ),
    );
  }
}

class EntryItem extends StatelessWidget {
  EntryItem(
      this.entry, this.allHour, this.allDay, this.allWeek, this.earthquakeData);

  final Entry entry;
  final List<Earthquake> allHour;
  final List<Earthquake> allDay;
  final List<Earthquake> allWeek;
  final EarthquakeData earthquakeData;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) {
      if (root.index != null) {
        var e;
        if (root.category == "hour") {
          e = allHour[root.index];
        } else if (root.category == "day") {
          e = allDay[root.index];
        } else {
          e = allWeek[root.index];
        }
        return new ListTile(
          title: new Text(root.title),
          subtitle: new Text(e.time),
          leading: new CircleAvatar(
            child: new Text(
              '${e.mag}',
              style: new TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
          onTap: () {
            print("tap");
            Marker marker;
            marker =
                new Marker("0", 'Mag: ${e.mag} | ${e.place}', e.lat, e.long);
            earthquakeData.showMapAtMarker(marker, allDay);
          },
        );
      } else {
        return new ListTile(
          title: new Text(root.title),
        );
      }
    }
    return new ExpansionTile(
      key: new PageStorageKey<Entry>(root),
      title: new Text(
        root.title,
        style: new TextStyle(color: Colors.black),
      ),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class Entry {
  Entry(this.title,
      {this.index, this.category, this.children = const <Entry>[]});

  final String title;
  final List<Entry> children;
  final int index;
  final String category;
}

// The entire multilevel list displayed by this app.
List<Entry> getExpansionData(List<Earthquake> allHour, List<Earthquake> allDay,
    List<Earthquake> allWeek) {
  List<Entry> hour = new List();
  List<Entry> day = new List();
  List<Entry> week = new List();

  int i;
  for (i = 0; i < allHour.length; i++) {
    if (i == 50) {
      break;
    }
    hour.add(new Entry('${allHour[i].place}', index: i, category: "hour"));
  }
  int afterHour = i;
  for (; i < allDay.length; i++) {
    if (i == 50 + afterHour) {
      day.add(new Entry("Only showing the last 50 earthquakes"));
      break;
    }
    day.add(new Entry('${allDay[i].place}', index: i, category: "day"));
  }
  int afterDay = i;
  for (; i < allWeek.length; i++) {
    if (i == 50 + afterDay + afterHour) {
      week.add(new Entry("Only showing the last 50 earthquakes"));
      debugPrint("Index: ${i.toString()}");
      break;
    }
    week.add(new Entry('${allWeek[i].place}', index: i, category: "week"));
  }

  return <Entry>[
    new Entry('Past Hour', children: hour),
    new Entry('Past Day', children: day),
    new Entry('Past Week', children: week),
  ];
}
