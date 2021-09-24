import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeChanger with ChangeNotifier {
  ThemeChanger(this._themeData) {
    loadPreferences();
  }

  ThemeData _themeData;

  Future<void> loadPreferences() async {
    final brightness = SchedulerBinding.instance.window.platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    setTheme(isDarkMode ? ThemeData.dark() : ThemeData.light());

    notifyListeners();
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }
}
