import 'package:dot/ui/theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dot/ui/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  _OnBoardState createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {

  final _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> splashData = [
    {
      "title": "DOT\nmeans\nDo on time",
      "subtitle":
      "DOT helps you to be always\non time. Track you tasks in the\ncleanest way possible.",
      "image": "assets/images/splash_1.png"
    },
    {
      "title": "Calender View",
      "subtitle":
      "Browse through a custom calender. See what you have coming up next\nand be on time.",
      "image": "assets/images/splash_2.png"
    },
    {
      "title": "Forget\nnothing",
      "subtitle":
      "Do your best in your day to day life\nby getting reminders.",
      "image": "assets/images/splash_3.png"
    },
  ];

  AnimatedContainer _buildDots({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: pinkClr,
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _controller,
                itemCount: splashData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Spacer(flex: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          splashData[index]['title']!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: bluishClr,
                          ),),
                        ),
                      ),
                      Spacer(flex: 1,),
                      Text(
                        splashData[index]['subtitle']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: darkHeaderClr,
                          height: 1.5,
                        ),)
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Spacer(),
                    ],
                  );
                },
                onPageChanged: (value) => setState(() => _currentPage = value),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                            (int index) => _buildDots(index: index),
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        child: FlatButton(
                          onPressed: () {
                            _currentPage+1 == splashData.length ?
                            Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => HomePage())
                            ):
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            );
                            _storeOnboardInfo();
                          },
                          child: Text(
                            _currentPage + 1 == splashData.length
                                ? 'Go to app'
                                : 'Continue',
                            style: GoogleFonts.lato(textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),)
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: yellowClr,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
