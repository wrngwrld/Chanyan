import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/board/list_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardListView extends StatelessWidget {
  BoardListView({
    @required this.board,
    @required this.snapshot,
    @required this.scrollController,
  });

  final String board;
  final AsyncSnapshot<List<Post>> snapshot;
  final ScrollController scrollController;

  setFavorite(Favorite favorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    if (favoriteThreadsPrefs == null) favoriteThreadsPrefs = [];

    if (favoriteThreadsPrefs.contains(json.encode(favorite))) return;

    String favoriteString = json.encode(favorite);

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
