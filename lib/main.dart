import 'package:earthquake_data_mapper/UI/expansion_tile.dart';
import 'package:earthquake_data_mapper/UI/header_card.dart';
import 'package:earthquake_data_mapper/UI/most_sig_list.dart';
import 'package:earthquake_data_mapper/UI/near_me.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'dart:async';

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
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> homePageWidgets = new List();

  @override
  void initState() {
    super.initState();
    refreshHomePage();
    setState(() {
      homePageWidgets = new List();
      homePageWidgets.add(new Padding(
        padding: const EdgeInsets.only(top: 16.0),
      ));
      homePageWidgets.add(new HeaderCard());
      homePageWidgets.add(new MostSigList());
      homePageWidgets.add(new NearMe());
      homePageWidgets.add(new ExpansionList());
    });
  }

  Future<Null> refreshHomePage() async {
    final Completer<Null> completer = new Completer();
    new Timer(const Duration(seconds: 1), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      setState(() {
        homePageWidgets = new List();
        homePageWidgets.add(new Padding(
          padding: const EdgeInsets.only(top: 16.0),
        ));
        homePageWidgets.add(new HeaderCard());
        homePageWidgets.add(new MostSigList());
        homePageWidgets.add(new NearMe());
        homePageWidgets.add(new ExpansionList());
      });
      scaffoldKey.currentState?.showSnackBar(
        new SnackBar(
          content: const Text('Refresh complete'),
          action: new SnackBarAction(
            label: 'RETRY',
            onPressed: () {
              refreshKey.currentState.show();
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Earthquake Data Mapper",
      home: new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new Text("Earthquake Data Mapper"),
          centerTitle: true,
        ),
        body: new RefreshIndicator(
          key: refreshKey,
          child: new ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: homePageWidgets,
          ),
          onRefresh: refreshHomePage,
        ),
      ),
    );
  }
}
