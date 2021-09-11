import 'package:flutter/material.dart';
import 'package:flutter_chan/pages/board_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chanyan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Montserrat',
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
        ),
      ),
      home: BoardList(),
    );
  }
}
