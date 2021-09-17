import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/pages/bottom_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoApp(
            color: CupertinoColors.activeGreen,
            home: BottomNavBar(),
          )
        : MaterialApp(
            title: 'Chanyan',
            theme: ThemeData(
              primarySwatch: Colors.lime,
              fontFamily: 'Montserrat',
              appBarTheme: AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: BottomNavBar(),
          );
  }
}
