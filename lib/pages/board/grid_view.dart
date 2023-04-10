import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/pages/board/grid_post.dart';

class BoardGridView extends StatelessWidget {
  const BoardGridView({
    Key? key,
    required this.board,
    required this.threads,
    required this.scrollController,
  }) : super(key: key);

  final String board;
  final List<Post> threads;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: GridView.count(
        padding: const EdgeInsets.only(top: 20),
        controller: scrollController,
        shrinkWrap: true,
        crossAxisCount: 2,
        children: [
          for (Post post in threads) GridPost(board: board, post: post),
        ],
      ),
    );
  }
}
