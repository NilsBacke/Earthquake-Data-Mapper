import 'package:earthquake_data_mapper/UI/expansion_tile.dart';
import 'package:earthquake_data_mapper/UI/header_card.dart';
import 'package:earthquake_data_mapper/UI/most_sig_list.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Earthquake Data Mapper",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Earthquake Data Mapper"),
          centerTitle: true,
        ),
        // body: new Container(
        //   child: new Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisSize: MainAxisSize.min,
        //     children: <Widget>[
        //       new Padding(
        //         padding: const EdgeInsets.only(top: 16.0),
        //       ),
        //       new HeaderCard(),
        //       new MostSigList(), // uncomment, save, then recomment
        //       new ExpansionList(),
        //     ],
        //   ),
        // ),
        body: new ListView(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(top: 16.0),
            ),
            new HeaderCard(),
            new MostSigList(), // uncomment, save, then recomment
            new ExpansionList(),
          ],
        ),
      ),
    );
  }
}
