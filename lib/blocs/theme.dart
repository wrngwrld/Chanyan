import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData) {
    loadPreferences();
  }

  loadPreferences() async {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    setTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());

    notifyListeners();
  }

  getTheme() => _themeData;

  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }
}
