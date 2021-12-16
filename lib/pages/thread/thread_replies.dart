import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page_post.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:provider/provider.dart';

class ThreadReplies extends StatefulWidget {
  const ThreadReplies({
    Key key,
    @required this.post,
    @required this.thread,
    @required this.board,
    @required this.replies,
  }) : super(key: key);

  final Post post;
  final int thread;
  final String board;
  final List<Post> replies;

  @override
  State<ThreadReplies> createState() => _ThreadRepliesState();
}

class _ThreadRepliesState extends State<ThreadReplies> {
  final ScrollController scrollController = ScrollController();

  List<Widget> media = [];
  List<String> fileNames = [];
  List<String> names = [];

  Future<void> getMedia(List<Post> list) async {
    for (final Post post in list) {
      if (post.tim != null) {
        final String video = post.tim.toString() + post.ext;

        names.add(post.filename + post.ext);
        fileNames.add(post.tim.toString() + post.ext);
        media.add(
          post.ext == '.webm'
              ? VLCPlayer(
                  board: widget.board,
                  video: video,
                  height: post.h,
                  width: post.w,
                  fileName: post.filename,
                )
              : InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: Image.network(
                    'https://i.4cdn.org/${widget.board}/$video',
                  ),
                ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    getMedia(widget.replies);

    return Scaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.black.withOpacity(0.8)
                  : CupertinoColors.white.withOpacity(0.8),
              previousPageTitle: 'back',
              middle: const Text('Replies'),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: const Text('Replies'),
            ),
      body: Scrollbar(
        controller: scrollController,
        child: ListView(
          shrinkWrap: false,
          controller: scrollController,
          children: [
            for (int i = 0; i < widget.replies.length; i++)
              ThreadPagePost(
                board: widget.board,
                thread: widget.thread,
                post: widget.replies[i],
                media: media,
                names: names,
                fileNames: fileNames,
              ),
          ],
        ),
      ),
    );
  }
}
