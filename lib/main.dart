import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/pages/bottom_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: BottomNavBar(),
    );
  }
}
