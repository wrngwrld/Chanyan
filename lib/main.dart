import 'package:flutter/material.dart';

import 'Boards.dart';

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
      home: Boards(id: 'gif', name: 'gif'),
    );
  }
}
