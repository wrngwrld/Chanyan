import 'package:flutter/material.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    loadPreferences();
  }

  bool allowNSFW = false;
  View boardView = View.gridView;
  Sort boardSort = Sort.byImagesCount;

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool allowNSFWPrefs = prefs.getBool('allowNSFW');
    final View boardViewPrefs = View.values.firstWhere(
      (element) => element.name == prefs.getString('boardView'),
    );
    final Sort boardSortPrefs = Sort.values.firstWhere(
      (element) => element.name == prefs.getString('boardSort'),
    );

    if (allowNSFWPrefs != null) {
      allowNSFW = allowNSFWPrefs;
    }
    if (boardViewPrefs != null) {
      boardView = boardViewPrefs;
    }
    if (boardSortPrefs != null) {
      boardSort = boardSortPrefs;
    }

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

  View getBoardView() {
    return boardView;
  }

  Future<void> setBoardView(View view) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    boardView = view;
    prefs.setString('boardView', view.name);

    notifyListeners();
  }

  Sort getBoardSort() {
    return boardSort;
  }

  Future<void> setBoardSort(Sort sort) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    boardSort = sort;
    prefs.setString('boardSort', sort.name);

    notifyListeners();
  }
}
