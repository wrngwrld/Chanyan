import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/bookmark_button.dart';
import 'package:flutter_chan/pages/thread/thread_grid_view.dart';
import 'package:flutter_chan/pages/thread/thread_page_post.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({
    Key key,
    @required this.board,
    @required this.thread,
    @required this.threadName,
    @required this.post,
    this.fromFavorites = false,
  }) : super(key: key);

  final String board;
  final int thread;
  final String threadName;
  final Post post;
  final bool fromFavorites;

  @override
  ThreadPageState createState() => ThreadPageState();
}

class ThreadPageState extends State<ThreadPage> {
  final ScrollController scrollController = ScrollController();

  List<Widget> media = [];
  List<String> fileNames = [];
  List<String> names = [];
  List<String> exts = [];
  List<int> tims = [];

  Favorite favorite;

  Future<void> getAllMedia() async {
    media = [];
    fileNames = [];
    names = [];

    final List<Post> posts =
        await fetchAllPostsFromThread(widget.board, widget.thread);

    for (final Post post in posts) {
      if (post.tim != null) {
        final String video = post.tim.toString() + post.ext;

        names.add(post.filename + post.ext);
        tims.add(post.tim);
        exts.add(post.ext);
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
      imageUrl: '${widget.post.tim}s.jpg',
      board: widget.board,
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
                  widget.fromFavorites ? 'bookmarks' : '/${widget.board}/',
              middle: Text(
                unescape(cleanTags(widget.threadName)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookmarkButton(
                    favorite: favorite,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ThreadGridView(
                            media: media,
                            fileNames: fileNames,
                            names: names,
                            board: widget.board,
                            tims: tims,
                            prevTitle: unescape(cleanTags(widget.threadName)),
                            exts: exts,
                          ),
                        ),
                      ),
                    },
                    child: const Icon(Icons.apps),
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
                                child: const Text('Reload'),
                                onPressed: () {
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Share'),
                                onPressed: () {
                                  Share.share(
                                      'https://boards.4chan.org/${widget.board}/thread/${widget.thread}');
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text(
                                  'Open in Browser',
                                ),
                                onPressed: () {
                                  launchURL(
                                      'https://boards.4chan.org/${widget.board}/thread/${widget.thread}');
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Download all Images'),
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
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text(
                unescape(cleanTags(widget.threadName)),
              ),
              actions: [
                BookmarkButton(
                  favorite: favorite,
                ),
                IconButton(
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ThreadGridView(
                          media: media,
                          fileNames: fileNames,
                          names: names,
                          board: widget.board,
                          tims: tims,
                          exts: exts,
                          prevTitle: unescape(cleanTags(widget.threadName)),
                        ),
                      ),
                    ),
                  },
                  icon: const Icon(Icons.apps),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Open in Browser'),
                      value: 0,
                    ),
                    const PopupMenuItem(
                      child: Text('Share'),
                      value: 1,
                    ),
                    const PopupMenuItem(
                      child: Text('Download all Images'),
                      value: 2,
                    ),
                  ],
                  onSelected: (int result) {
                    final String clipboardText =
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
        goDown: () => {
          scrollController.jumpTo(
            scrollController.position.maxScrollExtent,
          )
        },
        goUp: () => {
          scrollController.jumpTo(
            scrollController.position.minScrollExtent,
          )
        },
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
                  shrinkWrap: false,
                  controller: scrollController,
                  children: [
                    for (int i = 0; i < snapshot.data.length; i++)
                      ThreadPagePost(
                        board: widget.board,
                        thread: widget.thread,
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
