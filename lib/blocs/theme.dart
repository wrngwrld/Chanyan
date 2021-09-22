import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData) {
    loadPreferences();
  }

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _themeData = prefs.getString('darkMode') == 'dark'
        ? ThemeData.dark()
        : ThemeData.light();

    notifyListeners();
  }

  setPreferences(ThemeData data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('darkMode', data == ThemeData.dark() ? 'dark' : 'light');
  }

  getTheme() => _themeData;

  setTheme(ThemeData theme) {
    _themeData = theme;

    setPreferences(theme);

    notifyListeners();
  }
}
