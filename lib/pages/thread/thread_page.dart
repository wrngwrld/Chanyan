import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/gallery_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/bookmark_button.dart';
import 'package:flutter_chan/pages/thread/thread_grid_view.dart';
import 'package:flutter_chan/pages/thread/thread_page_post.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class ThreadPage extends StatefulWidget {
  const ThreadPage({
    Key? key,
    required this.board,
    required this.thread,
    required this.threadName,
    required this.post,
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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late Future<List<Post>> _fetchAllPostsFromThread;

  List<Widget> media = [];
  List<String> fileNames = [];
  List<int> tims = [];

  List<Post> allPosts = [];

  late Favorite favorite;
  late Post currentPage;

  Future<void> getAllMedia() async {
    media = [];
    fileNames = [];
    tims = [];

    final List<Post> posts =
        await fetchAllPostsFromThread(widget.board, widget.thread);

    for (final Post post in posts) {
      if (post.tim != null) {
        final String video = post.tim.toString() + post.ext.toString();

        tims.add(post.tim ?? 0);
        fileNames.add(post.tim.toString() + post.ext.toString());
        media.add(
          post.ext == '.webm'
              ? VLCPlayer(
                  board: widget.board,
                  video: video,
                  height: post.h ?? 0,
                  width: post.w ?? 0,
                  fileName: post.filename ?? '',
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

    _fetchAllPostsFromThread =
        fetchAllPostsFromThread(widget.board, widget.thread);
    getAllMedia();

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
    final gallery = Provider.of<GalleryProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.getTheme() == ThemeData.light()
          ? CupertinoColors.systemGroupedBackground
          : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        border: Border.all(color: Colors.transparent),
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
                      board: widget.board,
                      tims: tims,
                      prevTitle: unescape(cleanTags(widget.threadName)),
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
                    builder: (BuildContext context) => CupertinoActionSheet(
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
                          child: const Text('Download all Media'),
                          onPressed: () {
                            Navigator.pop(context);
                            saveAllMedia(
                              'https://i.4cdn.org/${widget.board}/',
                              fileNames,
                              _scaffoldKey.currentContext ?? context,
                            );
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
      ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
        goUp: () => {
          itemScrollController.scrollTo(
            index: 0,
            alignment: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          ),
        },
        goDown: () => {
          itemScrollController.scrollTo(
            index: allPosts.length,
            alignment: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          ),
        },
      ),
      body: FutureBuilder(
        future: _fetchAllPostsFromThread,
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: PlatformCircularProgressIndicator(
                  material: (_, __) =>
                      MaterialProgressIndicatorData(color: AppColors.kGreen),
                ),
              );
            default:
              allPosts = snapshot.data!;
              return SafeArea(
                top: true,
                bottom: false,
                child: ScrollablePositionedList.builder(
                  shrinkWrap: false,
                  itemCount: snapshot.data!.length,
                  physics: const ClampingScrollPhysics(),
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemBuilder: (context, index) => ThreadPagePost(
                    board: widget.board,
                    thread: widget.thread,
                    post: snapshot.data![index],
                    media: media,
                    fileNames: fileNames,
                    allPosts: snapshot.data ?? [],
                    onDismiss: (i) => {
                      if (gallery.getCurrentMedia() != '')
                        {
                          currentPage = allPosts
                              .where(
                                (element) =>
                                    element.tim.toString() ==
                                    gallery.getCurrentMedia(),
                              )
                              .toList()[0],
                          itemScrollController.scrollTo(
                            index: allPosts.indexOf(currentPage),
                            alignment: 0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          ),
                        },
                      gallery.setCurrentMedia(''),
                      gallery.setCurrentPage(0),
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
