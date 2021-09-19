import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmarks extends StatefulWidget {
  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  final ScrollController scrollController = ScrollController();

  Sort sortBy = Sort.byOldest;

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              middle: Text('Bookmarks'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          message: Text(
                            'Sort by',
                            style: TextStyle(color: AppColors.kBlack),
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
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text('Favorite Threads'),
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
            ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
      ),
      body: FutureBuilder(
        future: fetchFavoriteThreads(
          sortBy,
        ),
        builder:
            (BuildContext context, AsyncSnapshot<List<Favorite>> snapshot) {
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
              return snapshot.data.length == 0
                  ? Center(
                      child: Text(
                        'Add favorites first!',
                        style: TextStyle(
                          fontSize: 26,
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: scrollController,
                      child: ListView(
                        controller: scrollController,
                        children: [
                          for (int i = 0; i < snapshot.data.length; i++)
                            Dismissible(
                              background: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    Expanded(child: Container()),
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              key: Key(snapshot.data[i].toString()),
                              onDismissed: (direction) {
                                Favorite favorite = Favorite(
                                  no: snapshot.data[i].no,
                                  sub: snapshot.data[i].sub,
                                  replies: snapshot.data[i].replies,
                                  images: snapshot.data[i].images,
                                  com: snapshot.data[i].com,
                                  imageUrl: snapshot.data[i].imageUrl,
                                  board: snapshot.data[i].board,
                                );
                                removeFavorite(favorite);
                              },
                              child: InkWell(
                                onTap: () => {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) => ThreadPage(
                                            post: Post(
                                              no: snapshot.data[i].no,
                                              sub: snapshot.data[i].sub,
                                              replies: snapshot.data[i].replies,
                                              images: snapshot.data[i].images,
                                              com: snapshot.data[i].com,
                                              tim: int.parse(
                                                snapshot.data[i].imageUrl
                                                    .substring(
                                                        0,
                                                        snapshot
                                                                .data[i]
                                                                .imageUrl
                                                                .length -
                                                            5),
                                              ),
                                              board: snapshot.data[i].board,
                                            ),
                                            threadName:
                                                snapshot.data[i].sub != null
                                                    ? snapshot.data[i].sub
                                                        .toString()
                                                    : snapshot.data[i].com
                                                        .toString(),
                                            thread: snapshot.data[i].no,
                                            board: snapshot.data[i].board,
                                            fromFavorites: true,
                                          ),
                                        ),
                                      )
                                      .then((value) => {
                                            refreshPage(),
                                          })
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
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
                                          snapshot.data[i].imageUrl != null
                                              ? SizedBox(
                                                  width: 125,
                                                  height: 125,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.network(
                                                        'https://i.4cdn.org/${snapshot.data[i].board}/' +
                                                            snapshot.data[i]
                                                                .imageUrl,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'No.' +
                                                        snapshot.data[i].no
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  snapshot.data[i].sub != null
                                                      ? Text(
                                                          Stringz.unescape(Stringz
                                                              .cleanTags(snapshot
                                                                  .data[i].sub
                                                                  .toString())),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : Container(),
                                                  Text(
                                                    'R: ' +
                                                        snapshot.data[i].replies
                                                            .toString() +
                                                        ' / I: ' +
                                                        snapshot.data[i].images
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      snapshot.data[i].com != null
                                          ? Html(
                                              data: snapshot.data[i].com
                                                  .toString(),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    );
          }
        },
      ),
    );
  }
}
