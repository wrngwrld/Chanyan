import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksProvider with ChangeNotifier {
  List<String> list = [];
  Sort sort = Sort.byNewest;

  BookmarksProvider(this.list) {
    loadPreferences();
  }

  loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> bookmarksPrefs = prefs.getStringList('favoriteThreads');

    if (bookmarksPrefs == null) bookmarksPrefs = [];

    list = bookmarksPrefs;

    notifyListeners();
  }

  getBookmarks() {
    if (sort == Sort.byNewest)
      return list.reversed;
    else
      return list;
  }

  addBookmarks(Favorite favorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    list.add(json.encode(favorite));

    prefs.setStringList('favoriteThreads', list);

    notifyListeners();
  }

  removeBookmarks(Favorite favorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    list.remove(json.encode(favorite));

    prefs.setStringList('favoriteThreads', list);

    notifyListeners();
  }

  clearBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    list = [];

    prefs.setStringList('favoriteThreads', list);

    notifyListeners();
  }

  setSort(Sort sortBy) {
    sort = sortBy;

    notifyListeners();
  }
}
