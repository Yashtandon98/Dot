import 'package:dot/ui/onBoard.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dot/ui/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class splash extends StatefulWidget {
  @override
  _splashState createState() => _splashState();
}

class _splashState extends State<splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    starter();
  }

  starter() async {
    var d = new Duration(milliseconds: 2000);
    return new Timer(d, route);
  }

  route() {
    isViewed != 0 ?
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => OnBoard())
    ):
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomePage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width/4.5,
          height: MediaQuery.of(context).size.width/4.5,
          decoration: BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('images/logo.png'),
                  fit: BoxFit.fill,
                  scale: 0.2
              )
          ),
        ),
      ),
    );
  }
}
