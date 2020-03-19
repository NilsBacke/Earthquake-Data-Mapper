import 'package:earthquake_data_mapper/UI/expansion_tile.dart';
import 'package:earthquake_data_mapper/UI/header_card.dart';
import 'package:earthquake_data_mapper/UI/most_sig_list.dart';
import 'package:earthquake_data_mapper/UI/near_me.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:earthquake_data_mapper/UI/settings_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore db = Firestore.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final ENV = 'prod';

// Icon made by Freepik from www.flaticon.com

void main() {
  // MapView.setApiKey(apiInfo.apiKey);
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Earthquake Data Mapper",
    home: new Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Widget> homePageWidgets = new List();
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    setUpFirebaseMessaging();
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

    FirebaseAdMob.instance.initialize(
        appId: ENV == 'staging'
            ? FirebaseAdMob.testAppId
            : 'ca-app-pub-2682134172957549/3217764824');

    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['earthquake', 'earthquake map'],
      contentUrl: 'https://flutter.io',
      childDirected: false,
      testDevices: <String>[],
    );

    _bannerAd = BannerAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: ENV == 'staging'
          ? BannerAd.testAdUnitId
          : 'ca-app-pub-2682134172957549/3217764824',
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );

    _bannerAd
      // typically this happens well before the ad is shown
      ..load()
      ..show(
        anchorOffset: AppBar().preferredSize.height + 50,
        // Banner Position
        anchorType: AnchorType.top,
      );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  setUpFirebaseMessaging() async {
    _firebaseMessaging.requestNotificationPermissions(
        new IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    var token = await _firebaseMessaging.getToken();
    assert(token != null);
    print("Token: " + token);
    await saveCurrentLocation(token);
  }

  saveCurrentLocation(String token) async {
    var currentLocation = <String, double>{};

    var location = new Location();

    currentLocation = await location.getLocation();

    if (currentLocation == null) {
      return;
    }

    db.collection('locations').document(token).setData({
      'token': token,
      'latitude': currentLocation["latitude"],
      'longitude': currentLocation['longitude'],
    }, merge: true);

    var data = await db.collection('locations').document(token).get();
    if (data.data['maxDist'] == null) {
      db
          .collection('locations')
          .document(token)
          .setData({'maxDist': 250}, merge: true);
    }

    if (data.data['minMag'] == null) {
      db
          .collection('locations')
          .document(token)
          .setData({'minMag': 0}, merge: true);
    }
  }

  Future<Null> refreshHomePage() async {
    final Completer<Null> completer = new Completer();
    new Timer(const Duration(seconds: 2), () {
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

  void goToSettings() {
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text("Earthquake Data Mapper"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.settings),
            onPressed: goToSettings,
          )
        ],
      ),
      body: new Container(
        // color: const Color(0xFF404040),
        padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 40.0),
        color: Colors.grey[350],
        child: new RefreshIndicator(
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
