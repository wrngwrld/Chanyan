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
import 'package:flutter_chan/pages/favorite_button.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({
    Key key,
    @required this.board,
    @required this.boardName,
  }) : super(key: key);

  final String board;
  final String boardName;

  @override
  BoardPageState createState() => BoardPageState();
}

class BoardPageState extends State<BoardPage> {
  final ScrollController scrollController = ScrollController();

  Future<List<Post>> _fetchAllThreadsFromBoard;

  Sort sortBy = Sort.byImagesCount;
  View view = View.gridView;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    _fetchAllThreadsFromBoard = fetchAllThreadsFromBoard(sortBy, widget.board);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        previousPageTitle: 'Boards',
        backgroundColor: theme.getTheme() == ThemeData.dark()
            ? CupertinoColors.black.withOpacity(0.8)
            : CupertinoColors.white.withOpacity(0.8),
        middle: Text(
          '/${widget.board}/ - ${widget.boardName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FavoriteButton(board: widget.board),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    message: const Text(
                      'Sort by',
                      style: TextStyle(color: AppColors.kBlack),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                        child: const Text('Image Count'),
                        onPressed: () {
                          setState(() {
                            sortBy = Sort.byImagesCount;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Reply Count'),
                        onPressed: () {
                          setState(() {
                            sortBy = Sort.byReplyCount;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Bump Order'),
                        onPressed: () {
                          setState(() {
                            sortBy = Sort.byBumpOrder;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Newest'),
                        onPressed: () {
                          setState(() {
                            sortBy = Sort.byNewest;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Oldest'),
                        onPressed: () {
                          setState(() {
                            sortBy = Sort.byOldest;
                          });
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
                          child: const Text('Grid View'),
                          onPressed: () {
                            setState(() {
                              view = View.gridView;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text('List View'),
                          onPressed: () {
                            setState(() {
                              view = View.listView;
                            });
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
      ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
      ),
      body: FutureBuilder(
        future: _fetchAllThreadsFromBoard,
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
