import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/pages/bookmarks/bookmarks_post.dart';
import 'package:provider/provider.dart';

class Bookmarks extends StatefulWidget {
  const Bookmarks({Key key}) : super(key: key);

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  final ScrollController scrollController = ScrollController();

  Sort sortBy = Sort.byNewest;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final bookmarks = Provider.of<BookmarksProvider>(context);

    return CupertinoPageScaffold(
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
            if (Platform.isIOS)
              CupertinoSliverNavigationBar(
                border: Border.all(color: Colors.transparent),
                largeTitle: const Text('Bookmarks'),
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
                            message: const Text(
                              'Sort by',
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text('Newest'),
                                onPressed: () {
                                  bookmarks.setSort(Sort.byNewest);
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Oldest'),
                                onPressed: () {
                                  bookmarks.setSort(Sort.byOldest);
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
                      child: const Icon(Icons.sort),
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
                                  child: const Text('Clear bookmarks'),
                                  onPressed: () {
                                    bookmarks.clearBookmarks();
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
            else
              SliverAppBar(
                backgroundColor: AppColors.kGreen,
                foregroundColor: AppColors.kWhite,
                title: const Text('Bookmarks'),
                actions: [
                  PopupMenuButton(
                    icon: const Icon(Icons.sort),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        child: Text('Sort by newest'),
                        value: 0,
                      ),
                      const PopupMenuItem(
                        child: Text('Sort by oldest'),
                        value: 1,
                      ),
                    ],
                    onSelected: (int result) {
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
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        child: Text('Clear bookmarks'),
                        value: 0,
                      ),
                    ],
                    onSelected: (int result) {
                      switch (result) {
                        case 0:
                          bookmarks.clearBookmarks();

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
                return Future.delayed(const Duration(seconds: 1))
                  ..then((_) {
                    if (mounted) {
                      bookmarks.loadPreferences();
                    }
                  });
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (bookmarks.getBookmarks().isEmpty)
                    Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Add bookmarks first!',
                          style: TextStyle(
                            fontSize: 26,
                            color: theme.getTheme() == ThemeData.dark()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        for (String string in bookmarks.getBookmarks())
                          BookmarksPost(
                            favorite: Favorite.fromJson(
                              json.decode(string) as Map<String, dynamic>,
                            ),
                          )
                      ],
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
