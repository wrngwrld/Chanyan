import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmarks extends StatefulWidget {
  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  final ScrollController scrollController = ScrollController();

  Sort sortBy = Sort.byNewest;

  refreshPage() {
    setState(() {});
  }

  Future<List<Favorite>> fetchFavoriteThreads(Sort sort) async {
    List<Favorite> favorites = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    if (favoriteThreadsPrefs != null)
      for (String string in favoriteThreadsPrefs) {
        Favorite favorite = Favorite.fromJson(json.decode(string));

        favorites.add(favorite);
      }

    if (sort == Sort.byNewest) {
      favorites = favorites.reversed.toList();
    }

    return favorites;
  }

  Future<ThreadStatus> fetchArchived(String board, String thread) async {
    final Response response =
        await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

    if (response.statusCode == 200) {
      List<Post> posts = (jsonDecode(response.body)['posts'] as List)
          .map((model) => Post.fromJson(model))
          .toList();

      if (response.body == null) return ThreadStatus.deleted;

      if (posts[0].archived == 1) {
        return ThreadStatus.archived;
      } else {
        return ThreadStatus.online;
      }
    } else {
      return ThreadStatus.deleted;
    }
  }

  Future<List<int>> fetchReplies(String board, String thread) async {
    final Response response =
        await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

    if (response.statusCode == 200) {
      List<int> list = [];

      List<Post> posts = (jsonDecode(response.body)['posts'] as List)
          .map((model) => Post.fromJson(model))
          .toList();

      list.add(posts[0].replies);
      list.add(posts[0].images);

      return list;
    } else {
      throw Exception('Failed to load posts.');
    }
  }

  removeFavorite(Favorite favorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    favoriteThreadsPrefs.remove(json.encode(favorite));

    prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);

    refreshPage();
  }

  clearBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('favoriteThreads', []);

    refreshPage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return CupertinoPageScaffold(
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
            Platform.isIOS
                ? CupertinoSliverNavigationBar(
                    border: Border.all(color: Colors.transparent),
                    largeTitle: Text(
                      'Bookmarks',
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
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                message: Text(
                                  'Sort by',
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: Text('Newest'),
                                    onPressed: () {
                                      setState(() {
                                        sortBy = Sort.byNewest;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text('Oldest'),
                                    onPressed: () {
                                      setState(() {
                                        sortBy = Sort.byOldest;
                                      });
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
                          child: Icon(Icons.sort),
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
                                      child: Text('Clear bookmarks'),
                                      onPressed: () {
                                        clearBookmarks();
                                        refreshPage();
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
                : SliverAppBar(
                    backgroundColor: AppColors.kGreen,
                    foregroundColor: AppColors.kWhite,
                    title: Text(
                      'Bookmarks',
                    ),
                    actions: [
                      PopupMenuButton(
                        icon: Icon(Icons.sort),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text("Sort by newest"),
                            value: 0,
                          ),
                          PopupMenuItem(
                            child: Text("Sort by oldest"),
                            value: 1,
                          ),
                        ],
                        onSelected: (result) {
                          switch (result) {
                            case 0:
                              setState(() {
                                sortBy = Sort.byNewest;
                              });

                              break;
                            case 1:
                              setState(() {
                                sortBy = Sort.byOldest;
                              });

                              break;
                            default:
                          }
                        },
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text("Clear bookmarks"),
                            value: 0,
                          ),
                        ],
                        onSelected: (result) {
                          switch (result) {
                            case 0:
                              clearBookmarks();
                              refreshPage();
                              break;
                            default:
                          }
                        },
                      ),
                    ],
                    pinned: true,
                  ),
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return Future.delayed(Duration(seconds: 1))
                  ..then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  FutureBuilder(
                    future: fetchFavoriteThreads(
                      sortBy,
                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Favorite>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Column(
                            children: [
                              SizedBox(
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
                          return snapshot.data.length == 0
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      'Add bookmarks first!',
                                      style: TextStyle(
                                        fontSize: 26,
                                        color:
                                            theme.getTheme() == ThemeData.dark()
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    for (int i = 0;
                                        i < snapshot.data.length;
                                        i++)
                                      Slidable(
                                        actionPane: SlidableDrawerActionPane(),
                                        secondaryActions: <Widget>[
                                          IconSlideAction(
                                            caption: 'Delete',
                                            color: Colors.red,
                                            icon: Icons.delete,
                                            onTap: () {
                                              Favorite favorite = Favorite(
                                                no: snapshot.data[i].no,
                                                sub: snapshot.data[i].sub,
                                                com: snapshot.data[i].com,
                                                imageUrl:
                                                    snapshot.data[i].imageUrl,
                                                board: snapshot.data[i].board,
                                              );
                                              removeFavorite(favorite);
                                            },
                                          ),
                                        ],
                                        child: InkWell(
                                          onTap: () => {
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ThreadPage(
                                                      post: Post(
                                                        no: snapshot.data[i].no,
                                                        sub: snapshot
                                                            .data[i].sub,
                                                        com: snapshot
                                                            .data[i].com,
                                                        tim: int.parse(
                                                          snapshot
                                                              .data[i].imageUrl
                                                              .substring(
                                                                  0,
                                                                  snapshot
                                                                          .data[
                                                                              i]
                                                                          .imageUrl
                                                                          .length -
                                                                      5),
                                                        ),
                                                        board: snapshot
                                                            .data[i].board,
                                                      ),
                                                      threadName: snapshot
                                                                  .data[i]
                                                                  .sub !=
                                                              null
                                                          ? snapshot.data[i].sub
                                                              .toString()
                                                          : snapshot.data[i].com
                                                              .toString(),
                                                      thread:
                                                          snapshot.data[i].no,
                                                      board: snapshot
                                                          .data[i].board,
                                                      fromFavorites: true,
                                                    ),
                                                  ),
                                                )
                                                .then((value) => {
                                                      refreshPage(),
                                                    })
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 20),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: theme.getTheme() ==
                                                          ThemeData.dark()
                                                      ? CupertinoColors
                                                          .systemGrey
                                                      : Color(0x1F000000),
                                                  width: 0.15,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    snapshot.data[i].imageUrl !=
                                                            null
                                                        ? SizedBox(
                                                            width: 125,
                                                            height: 125,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image
                                                                    .network(
                                                                  'https://i.4cdn.org/${snapshot.data[i].board}/' +
                                                                      snapshot
                                                                          .data[
                                                                              i]
                                                                          .imageUrl,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            FutureBuilder(
                                                                future: fetchArchived(
                                                                    snapshot
                                                                        .data[i]
                                                                        .board,
                                                                    snapshot
                                                                        .data[i]
                                                                        .no
                                                                        .toString()),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            ThreadStatus>
                                                                        snapshot2) {
                                                                  switch (snapshot2
                                                                      .connectionState) {
                                                                    case ConnectionState
                                                                        .waiting:
                                                                      return Container();
                                                                      break;
                                                                    default:
                                                                      switch (snapshot2
                                                                          .data) {
                                                                        case ThreadStatus
                                                                            .archived:
                                                                          Text(
                                                                            'archived',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.red,
                                                                            ),
                                                                          );
                                                                          break;
                                                                        case ThreadStatus
                                                                            .deleted:
                                                                          Text(
                                                                            'deleted',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.red,
                                                                            ),
                                                                          );
                                                                          break;
                                                                        case ThreadStatus
                                                                            .online:
                                                                          Container();
                                                                          break;
                                                                        default:
                                                                          Container();
                                                                      }
                                                                      return snapshot2.data ==
                                                                              ThreadStatus.archived
                                                                          ? Text(
                                                                              'archived',
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.red,
                                                                              ),
                                                                            )
                                                                          : Container();
                                                                  }
                                                                }),
                                                            Text(
                                                              'No.' +
                                                                  snapshot
                                                                      .data[i]
                                                                      .no
                                                                      .toString(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: theme.getTheme() ==
                                                                        ThemeData
                                                                            .dark()
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            snapshot.data[i]
                                                                        .sub !=
                                                                    null
                                                                ? Text(
                                                                    Stringz.unescape(Stringz.cleanTags(snapshot
                                                                        .data[i]
                                                                        .sub
                                                                        .toString())),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: theme.getTheme() ==
                                                                              ThemeData
                                                                                  .dark()
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            FutureBuilder(
                                                              future: fetchReplies(
                                                                  snapshot
                                                                      .data[i]
                                                                      .board,
                                                                  snapshot
                                                                      .data[i]
                                                                      .no
                                                                      .toString()),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot<
                                                                          List<
                                                                              int>>
                                                                      snapshot3) {
                                                                switch (snapshot3
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .waiting:
                                                                    return Text(
                                                                      'R: - / I: -',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: theme.getTheme() ==
                                                                                ThemeData.dark()
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                      ),
                                                                    );
                                                                    break;
                                                                  default:
                                                                    return Text(
                                                                      'R: ' +
                                                                          snapshot3.data[0]
                                                                              .toString() +
                                                                          ' / I: ' +
                                                                          snapshot3
                                                                              .data[1]
                                                                              .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: theme.getTheme() ==
                                                                                ThemeData.dark()
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                      ),
                                                                    );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                snapshot.data[i].com != null
                                                    ? Html(
                                                        data: snapshot
                                                            .data[i].com
                                                            .toString(),
                                                        style: {
                                                          "body": Style(
                                                            color: theme.getTheme() ==
                                                                    ThemeData
                                                                        .dark()
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        },
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
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
