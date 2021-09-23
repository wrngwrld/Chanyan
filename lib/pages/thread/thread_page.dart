import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/bookmark_button.dart';
import 'package:flutter_chan/pages/thread/thread_page_post.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ThreadPage extends StatefulWidget {
  ThreadPage({
    @required this.board,
    @required this.thread,
    @required this.threadName,
    @required this.post,
    this.fromFavorites = false,
  });

  final board;
  final thread;
  final threadName;
  final Post post;
  final bool fromFavorites;

  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final ScrollController scrollController = ScrollController();

  List<Widget> media = [];
  List<String> fileNames = [];
  List<String> names = [];

  Favorite favorite;

  getAllMedia() async {
    List<Post> posts =
        await fetchAllPostsFromThread(widget.board, widget.thread);

    for (Post post in posts) {
      if (post.tim != null) {
        String video = post.tim.toString() + post.ext.toString();

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
                      'https://i.4cdn.org/${widget.board}/$video'),
                ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    favorite = Favorite(
      no: widget.post.no,
      sub: widget.post.sub,
      com: widget.post.com,
      imageUrl: widget.post.tim.toString() + 's.jpg',
      board: widget.board.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.black.withOpacity(0.8)
                  : CupertinoColors.white.withOpacity(0.8),
              previousPageTitle:
                  widget.fromFavorites ? 'bookmarks' : '/' + widget.board + '/',
              middle: Text(
                Stringz.unescape(Stringz.cleanTags(widget.threadName)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookmarkButton(
                    favorite: favorite,
                  ),
                  SizedBox(
                    width: 20,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                child: Text(
                                  'Open in Browser',
                                ),
                                onPressed: () {
                                  launchURL(
                                      'https://boards.4chan.org/${widget.board}/thread/${widget.thread}');
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Share'),
                                onPressed: () {
                                  Share.share(
                                      'https://boards.4chan.org/${widget.board}/thread/${widget.thread}');
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Download all Images'),
                                onPressed: () {
                                  saveAllMedia(
                                    'https://i.4cdn.org/${widget.board}/',
                                    fileNames,
                                    context,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text(
                Stringz.unescape(Stringz.cleanTags(widget.threadName)),
              ),
              actions: [
                BookmarkButton(
                  favorite: favorite,
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Open in Browser"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Share"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Download all Images"),
                      value: 2,
                    ),
                  ],
                  onSelected: (result) {
                    String clipboardText =
                        'https://boards.4chan.org/${widget.board}/thread/${widget.thread}';

                    switch (result) {
                      case 0:
                        launchURL(
                            'https://boards.4chan.org/${widget.board}/thread/${widget.thread}');
                        break;
                      case 1:
                        Share.share(clipboardText);
                        break;
                      case 2:
                        saveAllMedia(
                          'https://i.4cdn.org/${widget.board}/',
                          fileNames,
                          context,
                        );
                        break;
                      default:
                    }
                  },
                )
              ],
            ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
      ),
      body: FutureBuilder(
        future: fetchAllPostsFromThread(widget.board, widget.thread),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
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
              getAllMedia();
              return Scrollbar(
                controller: scrollController,
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (int i = 0; i < snapshot.data.length; i++)
                      ThreadPagePost(
                        board: widget.board,
                        post: snapshot.data[i],
                        media: media,
                        names: names,
                        fileNames: fileNames,
                      ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
