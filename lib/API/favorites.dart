import 'package:shared_preferences/shared_preferences.dart';

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
