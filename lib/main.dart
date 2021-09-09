import 'package:flutter/material.dart';
import 'package:flutter_chan/thread.dart';

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
      ),
      home: Thread(id: '20797400', name: 'SEX'),
    );
  }
}
