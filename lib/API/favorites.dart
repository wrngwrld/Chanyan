import 'dart:convert';

import 'package:flutter_chan/Models/favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isBookmarkCheck(Favorite favorite) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  return favoriteThreadsPrefs.contains(json.encode(favorite));
}

addBookmark(Favorite favorite) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  if (favoriteThreadsPrefs == null) favoriteThreadsPrefs = [];

  if (favoriteThreadsPrefs.contains(json.encode(favorite))) return;

  String favoriteString = json.encode(favorite);

  favoriteThreadsPrefs.add(favoriteString);

  prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);
}

removeBookmark(Favorite favorite) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  favoriteThreadsPrefs.remove(json.encode(favorite));

  prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);
}

isFavoriteCheck(String board) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteBoards = prefs.getStringList('favoriteBoards');

  if (favoriteBoards == null) favoriteBoards = [];

  if (favoriteBoards.contains(board)) return true;

  return false;
}

addFavorites(String board) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

  if (favoriteBoardsPref == null) favoriteBoardsPref = [];

  if (!favoriteBoardsPref.contains(board)) favoriteBoardsPref.add(board);

  prefs.setStringList('favoriteBoards', favoriteBoardsPref);
}

removeFromFavorites(String board) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

  favoriteBoardsPref.remove(board);

  prefs.setStringList('favoriteBoards', favoriteBoardsPref);
}
