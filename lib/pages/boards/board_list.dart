import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/Models/board.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/favorite_model.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/boards/board_tile.dart';
import 'package:flutter_chan/pages/bookmarks/bookmarks.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../settings/settings.dart';

class BoardList extends StatefulWidget {
  const BoardList({Key key}) : super(key: key);

  @override
  BoardListState createState() => BoardListState();
}

class BoardListState extends State<BoardList> {
  Future<List<Board>> _fetchAllBoards;
  TextEditingController controller = TextEditingController();

  bool showWarning = false;
  String warningText = 'This link is not supported';

  @override
  void initState() {
    super.initState();

    _fetchAllBoards = fetchAllBoards();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final favorites = Provider.of<FavoriteProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    Future<bool> openURL() async {
      try {
        controller.text = controller.text.trim();
        final regExDomains =
            RegExp(r'^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www.)?([^:\/\n?]+)');
        final matchDomain = regExDomains.firstMatch(controller.text);
        final domain = matchDomain.group(1);

        if (domain == 'boards.4chan.org' || domain == 'boards.4channel.org') {
          final regEx = RegExp(r'^https?:\/\/[A-Za-z0-9:.]*([\/]{1}.*\/?)$');
          final match = regEx.firstMatch(controller.text);
          final removedFirst = match.group(1).replaceFirst('/', '');
          final splitted = removedFirst.split('/');

          List<Post> response;

          try {
            response = await fetchAllPostsFromThread(
                splitted.first, int.parse(splitted.last));
          } catch (e) {
            showWarning = true;
            warningText = e.toString();
            return true;
          }

          controller.clear();

          Navigator.of(context).pop();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadPage(
                post: response[0],
                threadName: response[0].sub ?? response[0].com,
                thread: response[0].no,
                board: splitted.first,
              ),
            ),
          );

          return false;
        } else {
          warningText = 'This link is not supported';
          return true;
        }
      } catch (e) {
        showWarning = true;
        warningText = e.toString();
        return true;
      }
    }

    return CupertinoPageScaffold(
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              border: Border.all(color: Colors.transparent),
              leading: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => {
                        showWarning = false,
                        showCupertinoDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return CupertinoAlertDialog(
                                  title: const Text('Open Link'),
                                  content: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Visibility(
                                        visible: showWarning,
                                        child: Column(
                                          children: [
                                            Text(
                                              warningText,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Card(
                                        color: Colors.transparent,
                                        elevation: 0.0,
                                        child: Column(
                                          children: [
                                            CupertinoTextField(
                                              controller: controller,
                                              placeholder: 'Insert Thread URL',
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text(
                                        'Open',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                      onPressed: () => {
                                        openURL().then(
                                          (value) => {
                                            if (value)
                                              {
                                                setState(() {
                                                  showWarning = true;
                                                }),
                                              },
                                          },
                                        )
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      },
                      child: const Text(
                        'Open Link',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              largeTitle: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Text(
                  'Chanyan',
                  style: TextStyle(
                    color: theme.getTheme() == ThemeData.dark()
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
              ),
              backgroundColor: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.black.withOpacity(0.8)
                  : CupertinoColors.white.withOpacity(0.8),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Bookmarks(),
                        ),
                      );
                    },
                    child: const Icon(CupertinoIcons.heart),
                  ),
                  SizedBox(
                    width: 20,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Settings(),
                          ),
                        );
                      },
                      child: const Icon(CupertinoIcons.settings),
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return Future.delayed(const Duration(seconds: 1))
                  ..then((_) {
                    if (mounted) {
                      favorites.loadPreferences();
                    }
                  });
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  FutureBuilder(
                    future: _fetchAllBoards,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Board>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Column(
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              PlatformCircularProgressIndicator(
                                material: (_, __) =>
                                    MaterialProgressIndicatorData(
                                        color: AppColors.kGreen),
                              ),
                            ],
                          );
                          break;
                        default:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 5, 10),
                                child: Text(
                                  'favorites',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              for (Board board in snapshot.data)
                                settings.getNSFW()
                                    ? BoardTile(board: board, favorites: true)
                                    : board.wsBoard == 0
                                        ? Container()
                                        : BoardTile(
                                            board: board, favorites: true),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 5, 10),
                                child: Text(
                                  'all',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              for (Board board in snapshot.data)
                                settings.getNSFW()
                                    ? BoardTile(board: board, favorites: false)
                                    : board.wsBoard == 0
                                        ? Container()
                                        : BoardTile(
                                            board: board, favorites: false),
                            ],
                          );
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
