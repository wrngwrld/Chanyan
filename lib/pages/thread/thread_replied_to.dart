import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page_post.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ThreadRepliesTo extends StatefulWidget {
  const ThreadRepliesTo({
    Key key,
    @required this.post,
    @required this.thread,
    @required this.board,
    @required this.allPosts,
  }) : super(key: key);

  final int post;
  final int thread;
  final String board;
  final List<Post> allPosts;

  @override
  State<ThreadRepliesTo> createState() => _ThreadRepliesToState();
}

class _ThreadRepliesToState extends State<ThreadRepliesTo> {
  final ScrollController scrollController = ScrollController();

  Future<Post> _fetchPost;

  List<Widget> media = [];
  List<String> fileName = [];
  List<String> name = [];

  Future<void> getMedia(Post post) async {
    if (post.tim != null) {
      final String video = post.tim.toString() + post.ext;

      name.add(post.filename + post.ext);
      fileName.add(post.tim.toString() + post.ext);
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

  @override
  void initState() {
    super.initState();

    _fetchPost = fetchPost(widget.board, widget.thread, widget.post);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.dark()
            ? CupertinoColors.black.withOpacity(0.8)
            : CupertinoColors.white.withOpacity(0.8),
        previousPageTitle: 'back',
        middle: const Text('Replies'),
      ),
      body: FutureBuilder(
        future: _fetchPost,
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: PlatformCircularProgressIndicator(
                  material: (_, __) =>
                      MaterialProgressIndicatorData(color: AppColors.kGreen),
                ),
              );
              break;
            default:
              getMedia(snapshot.data);
              return ListView(
                shrinkWrap: false,
                controller: scrollController,
                children: [
                  Scrollbar(
                    controller: scrollController,
                    child: ThreadPagePost(
                      board: widget.board,
                      thread: widget.thread,
                      post: snapshot.data,
                      media: media,
                      names: name,
                      fileNames: fileName,
                      allPosts: widget.allPosts,
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
