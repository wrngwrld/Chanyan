import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  FavoriteProvider(this.list) {
    loadPreferences();
  }

  List<String> list = [];
  Sort sort = Sort.byNewest;

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoritePrefs = prefs.getStringList('favoriteBoards');

    favoritePrefs ??= [];

    list = favoritePrefs;

    notifyListeners();
  }

  List<String> getFavorites() => list;

  Future<void> addFavorites(String board) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!list.contains(board)) {
      list.add(board);
      prefs.setStringList('favoriteBoards', list);
    }

    notifyListeners();
  }

  Future<void> removeFavorites(String board) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    list.remove(board);

    prefs.setStringList('favoriteBoards', list);

    notifyListeners();
  }
}
