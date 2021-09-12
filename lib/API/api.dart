import 'dart:convert';

import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:flutter_chan/models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Post>> fetchOPs(Sort sorting, String board) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/catalog.json'));

  List<Post> ops = List.empty(growable: true);
  List pages = jsonDecode(response.body);

  if (response.statusCode == 200) {
    pages.forEach((page) {
      List opsInPage = page['threads'];
      opsInPage.forEach((opInPage) {
        ops.add(Post.fromJson(opInPage));
      });
    });

    // Thread sorting
    if (sorting != null) {
      switch (sorting) {
        case Sort.byBumpOrder:
          ops.sort((a, b) {
            return a.lastModified.compareTo(b.lastModified);
          });
          break;
        case Sort.byReplyCount:
          ops.sort((a, b) {
            return b.replies.compareTo(a.replies);
          });
          break;
        case Sort.byImagesCount:
          ops.sort((a, b) {
            return b.images.compareTo(a.images);
          });
          break;
        case Sort.byNewest:
          ops.sort((a, b) {
            return b.time.compareTo(a.time);
          });
          break;
        case Sort.byOldest:
          ops.sort((a, b) {
            return a.time.compareTo(b.time);
          });
          break;
      }
    }

    return ops;
  } else {
    throw Exception('Failed to load OPs.');
  }
}

Future<List<Post>> fetchPosts(String board, int thread) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

  if (response.statusCode == 200) {
    List<Post> posts = (jsonDecode(response.body)['posts'] as List)
        .map((model) => Post.fromJson(model))
        .toList();
    return posts;
  } else {
    throw Exception('Failed to load posts.');
  }
}

Future<List<Board>> fetchBoards() async {
  Response response = await get(Uri.parse('https://a.4cdn.org/boards.json'));

  if (response.statusCode == 200) {
    List<Board> boards = (jsonDecode(response.body)['boards'] as List)
        .map((model) => Board.fromJson(model))
        .toList();
    return boards;
  } else {
    throw Exception('Failed to load boards.');
  }
}

Future<Favorite> fetchFavorites() async {
  Favorite favorite = Favorite();

  List<Post> postList = [];
  List<String> boardList = [];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

  for (String string in favoriteThreadsPrefs) {
    List<String> list = string.split(',');
    final Response response = await get(
        Uri.parse('https://a.4cdn.org/${list[0]}/thread/${list[1]}.json'));

    if (response.statusCode == 200) {
      List<Post> posts = (jsonDecode(response.body)['posts'] as List)
          .map((model) => Post.fromJson(model))
          .toList();
      postList.add(posts[0]);

      boardList.add(list[0]);
    } else {
      throw Exception('Failed to load posts.');
    }
  }

  favorite.boards = boardList;
  favorite.posts = postList;

  return favorite;
}
