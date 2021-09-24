import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/board/list_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardListView extends StatelessWidget {
  const BoardListView({
    Key key,
    @required this.board,
    @required this.snapshot,
    @required this.scrollController,
  }) : super(key: key);

  final String board;
  final AsyncSnapshot<List<Post>> snapshot;
  final ScrollController scrollController;

  Future<void> setFavorite(Favorite favorite) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    favoriteThreadsPrefs ??= [];

    if (favoriteThreadsPrefs.contains(json.encode(favorite))) {
      return;
    }

    final String favoriteString = json.encode(favorite);

    favoriteThreadsPrefs.add(favoriteString);

    prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        children: [
          for (Post post in snapshot.data) ListPost(board: board, post: post)
        ],
      ),
    );
  }
}
