import 'package:flutter/material.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    loadPreferences();
  }

  bool allowNSFW = false;
  View boardView = View.gridView;

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool allowNSFWPrefs = prefs.getBool('allowNSFW');
    final View boardViewPrefs = View.values.firstWhere(
      (element) => element.name == prefs.getString('boardView'),
    );

    if (allowNSFWPrefs == null) {
      allowNSFW = false;
    }

    if (boardViewPrefs == null) {
      boardView = View.gridView;
    }

    allowNSFW = allowNSFWPrefs;
    boardView = boardViewPrefs;

    notifyListeners();
  }

  bool getNSFW() {
    if (allowNSFW == null) {
      return false;
    } else {
      return allowNSFW;
    }
  }

  Future<void> setNSFW(bool boolean) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    allowNSFW = boolean;
    prefs.setBool('allowNSFW', boolean);

    notifyListeners();
  }

  View getBoardView() {
    if (boardView == null) {
      return View.gridView;
    } else {
      return boardView;
    }
  }

  Future<void> setBoardView(View view) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    boardView = view;
    prefs.setString('boardView', view.name);

    notifyListeners();
  }
}
