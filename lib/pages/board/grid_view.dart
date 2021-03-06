import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/pages/board/grid_post.dart';

class BoardGridView extends StatelessWidget {
  const BoardGridView({
    Key key,
    @required this.board,
    @required this.snapshot,
    @required this.scrollController,
  }) : super(key: key);

  final String board;
  final AsyncSnapshot<List<Post>> snapshot;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: GridView.count(
        controller: scrollController,
        crossAxisCount: 2,
        children: [
          for (Post post in snapshot.data) GridPost(board: board, post: post),
        ],
      ),
    );
  }
}
