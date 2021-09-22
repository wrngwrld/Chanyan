import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/board/grid_view.dart';
import 'package:flutter_chan/pages/board/list_view.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardPage extends StatefulWidget {
  BoardPage({
    @required this.board,
    @required this.boardName,
  });

  final board;
  final boardName;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ScrollController scrollController = ScrollController();

  Sort sortBy = Sort.byImagesCount;
  View view = View.gridView;

  bool isFavorite = false;

  fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteBoards = prefs.getStringList('favoriteBoards');

    if (favoriteBoards == null) favoriteBoards = [];

    setState(() {
      if (favoriteBoards.contains(widget.board)) isFavorite = true;
    });
  }

  addToFavorites(String board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

    if (favoriteBoardsPref == null) favoriteBoardsPref = [];

    if (!favoriteBoardsPref.contains(board)) favoriteBoardsPref.add(board);

    setState(() {
      isFavorite = true;
    });

    prefs.setStringList('favoriteBoards', favoriteBoardsPref);
  }

  removeFromFavorites(String board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

    favoriteBoardsPref.remove(board);

    setState(() {
      isFavorite = false;
    });

    prefs.setStringList('favoriteBoards', favoriteBoardsPref);
  }

  @override
  void initState() {
    super.initState();

    fetchFavorites();
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
              previousPageTitle: 'Boards',
              backgroundColor: theme.getTheme() == ThemeData.light()
                  ? Colors.white
                  : Colors.black,
              middle: Text(
                '/' + widget.board + '/ - ' + widget.boardName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      isFavorite
                          ? removeFromFavorites(widget.board)
                          : addToFavorites(widget.board);
                    },
                    child: Icon(
                      isFavorite ? Icons.star_rate : Icons.star_outline,
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
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
                              child: Text('Image Count'),
                              onPressed: () {
                                setState(() {
                                  sortBy = Sort.byImagesCount;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Reply Count'),
                              onPressed: () {
                                setState(() {
                                  sortBy = Sort.byReplyCount;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Bump Order'),
                              onPressed: () {
                                setState(() {
                                  sortBy = Sort.byBumpOrder;
                                });
                                Navigator.pop(context);
                              },
                            ),
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
                                child: Text('Grid View'),
                                onPressed: () {
                                  setState(() {
                                    view = View.gridView;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('List View'),
                                onPressed: () {
                                  setState(() {
                                    view = View.listView;
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
                      child: Icon(
                        Icons.more_vert,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text(
                '/' + widget.board + '/ - ' + widget.boardName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    isFavorite
                        ? removeFromFavorites(widget.board)
                        : addToFavorites(widget.board);
                  },
                  icon: Icon(
                    isFavorite ? Icons.star_rate : Icons.star_outline,
                    color: AppColors.kWhite,
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.sort),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Sort by image count"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by reply count"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by bump order"),
                      value: 2,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by newest"),
                      value: 3,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by oldest"),
                      value: 4,
                    ),
                  ],
                  onSelected: (result) {
                    switch (result) {
                      case 0:
                        setState(() {
                          sortBy = Sort.byImagesCount;
                        });
                        break;
                      case 1:
                        setState(() {
                          sortBy = Sort.byReplyCount;
                        });

                        break;
                      case 2:
                        setState(() {
                          sortBy = Sort.byBumpOrder;
                        });

                        break;
                      case 3:
                        setState(() {
                          sortBy = Sort.byNewest;
                        });

                        break;
                      case 4:
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
                      child: Text("Grid view"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("List view"),
                      value: 1,
                    ),
                  ],
                  onSelected: (result) {
                    switch (result) {
                      case 0:
                        setState(() {
                          view = View.gridView;
                        });
                        break;
                      case 1:
                        setState(() {
                          view = View.listView;
                        });

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
        future: fetchAllThreadsFromBoard(sortBy, widget.board),
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
              switch (view) {
                case View.listView:
                  return BoardListView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
                  break;
                case View.gridView:
                  return BoardGridView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
                  break;
                default:
                  return BoardListView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
              }
          }
        },
      ),
    );
  }
}
