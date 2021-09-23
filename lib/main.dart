import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(ThemeData.dark()), child: AppWithTheme());
  }
}

class AppWithTheme extends StatefulWidget {
  @override
  State<AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<AppWithTheme>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;

    final theme = Provider.of<ThemeChanger>(context, listen: false);

    theme.setTheme(
        brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light());

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Platform.isIOS
        ? CupertinoApp(
            color: CupertinoColors.activeGreen,
            home: BottomNavBar(),
            theme: CupertinoThemeData(
              brightness: theme.getTheme() == ThemeData.dark()
                  ? Brightness.dark
                  : Brightness.light,
            ),
          )
        : MaterialApp(
            title: 'Chanyan',
            theme: theme.getTheme(),
            debugShowCheckedModeBanner: false,
            home: BottomNavBar(),
          );
  }
}
