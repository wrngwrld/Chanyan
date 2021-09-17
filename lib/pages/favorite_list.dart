import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/favorite.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList extends StatefulWidget {
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  final ScrollController scrollController = ScrollController();

  refreshPage() {
    setState(() {});
  }

  removeFavorite(String board, String thread) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    favoriteThreadsPrefs.remove('$board,$thread');

    prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);

    refreshPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: CupertinoColors.white.withOpacity(0.85),
              middle: Text('Favorite Threads'),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text('Favorite Threads'),
            ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
      ),
      body: FutureBuilder(
        future: fetchFavoriteThreads(),
        builder: (BuildContext context, AsyncSnapshot<Favorite> snapshot) {
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
              return snapshot.data.boards.length == 0
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
                          for (int i = 0; i < snapshot.data.posts.length; i++)
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
                              key: Key(snapshot.data.posts[i].toString()),
                              onDismissed: (direction) {
                                setState(() {
                                  removeFavorite(
                                    snapshot.data.boards[i],
                                    snapshot.data.posts[i].no.toString(),
                                  );
                                });
                              },
                              child: InkWell(
                                onTap: () => {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) => ThreadPage(
                                            threadName:
                                                snapshot.data.posts[i].sub !=
                                                        null
                                                    ? snapshot.data.posts[i].sub
                                                        .toString()
                                                    : snapshot.data.posts[i].com
                                                        .toString(),
                                            thread: snapshot.data.posts[i].no,
                                            board: snapshot.data.boards[i],
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
                                          snapshot.data.posts[i].tim != null
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
                                                        'https://i.4cdn.org/${snapshot.data.boards[i]}/' +
                                                            snapshot.data
                                                                .posts[i].tim
                                                                .toString() +
                                                            's.jpg',
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
                                                  snapshot.data.posts[i]
                                                              .archived !=
                                                          null
                                                      ? Text(
                                                          'Archived',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Container(),
                                                  Text(
                                                    'No.' +
                                                        snapshot
                                                            .data.posts[i].no
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  snapshot.data.posts[i].sub !=
                                                          null
                                                      ? Text(
                                                          snapshot
                                                              .data.posts[i].sub
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : Container(),
                                                  Text(
                                                    'R: ' +
                                                        snapshot.data.posts[i]
                                                            .replies
                                                            .toString() +
                                                        ' / I: ' +
                                                        snapshot.data.posts[i]
                                                            .images
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
                                      snapshot.data.posts[i].com != null
                                          ? Html(
                                              data: snapshot.data.posts[i].com
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
