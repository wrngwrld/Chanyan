import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    loadPreferences();
  }

  bool allowNSFW = false;

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool allowNSFWPrefs = prefs.getBool('allowNSFW');

    if (allowNSFWPrefs == null) {
      allowNSFW = false;
    }

    allowNSFW = allowNSFWPrefs;

    notifyListeners();
  }

  bool getNSFW() {
    return allowNSFW;
  }

  Future<void> setNSFW(bool boolean) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    allowNSFW = boolean;

    prefs.setBool('allowNSFW', boolean);

    notifyListeners();
  }
}
