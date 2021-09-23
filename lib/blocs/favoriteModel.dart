import 'package:flutter/material.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> list = [];
  Sort sort = Sort.byNewest;

  FavoriteProvider(this.list) {
    loadPreferences();
  }

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoritePrefs = prefs.getStringList('favoriteBoards');

    if (favoritePrefs == null) favoritePrefs = [];

    list = favoritePrefs;

    notifyListeners();
  }

  getFavorites() => list;

  addFavorites(String board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!list.contains(board)) {
      list.add(board);
      prefs.setStringList('favoriteBoards', list);
    }

    notifyListeners();
  }

  removeFavorites(String board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    list.remove(board);

    prefs.setStringList('favoriteBoards', list);

    notifyListeners();
  }
}
