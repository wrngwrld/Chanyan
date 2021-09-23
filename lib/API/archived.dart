import 'dart:convert';

import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThreadStatus> fetchArchived(String board, String thread) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

  if (response.statusCode == 200) {
    List<Post> posts = (jsonDecode(response.body)['posts'] as List)
        .map((model) => Post.fromJson(model))
        .toList();

    if (response.body == null) return ThreadStatus.deleted;

    if (posts[0].archived == 1) {
      return ThreadStatus.archived;
    } else {
      return ThreadStatus.online;
    }
  } else {
    return ThreadStatus.deleted;
  }
}

Future<List<Favorite>> fetchFavoriteThreads(Sort sort) async {
  List<Favorite> favorites = [];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  if (favoriteThreadsPrefs != null)
    for (String string in favoriteThreadsPrefs) {
      Favorite favorite = Favorite.fromJson(json.decode(string));

      favorites.add(favorite);
    }

  if (sort == Sort.byNewest) {
    favorites = favorites.reversed.toList();
  }

  return favorites;
}

Future<List<int>> fetchReplies(String board, String thread) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

  if (response.statusCode == 200) {
    List<int> list = [];

    List<Post> posts = (jsonDecode(response.body)['posts'] as List)
        .map((model) => Post.fromJson(model))
        .toList();

    list.add(posts[0].replies);
    list.add(posts[0].images);

    return list;
  } else {
    throw Exception('Failed to load posts.');
  }
}

removeFavorite(Favorite favorite) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  favoriteThreadsPrefs.remove(json.encode(favorite));

  prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);

  // refreshPage();
}

clearBookmarks() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setStringList('favoriteThreads', []);

  // refreshPage();
}
