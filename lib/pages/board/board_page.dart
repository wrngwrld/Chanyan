import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
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

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _fetchAllThreadsFromBoard =
        fetchAllThreadsFromBoard(settings.getBoardSort(), widget.board);
  }

  void setSort(Sort sortBy, SettingsProvider settings) {
    setState(() {
      _fetchAllThreadsFromBoard =
          fetchAllThreadsFromBoard(sortBy, widget.board);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final Sort boardSort = settings.getBoardSort();

    return Scaffold(
      backgroundColor: theme.getTheme() == ThemeData.light()
          ? CupertinoColors.systemGroupedBackground
          : Colors.black,
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        previousPageTitle: 'Boards',
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        middle: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Text(
            '/${widget.board}/ - ${widget.boardName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        border: Border.all(color: Colors.transparent),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FavoriteButton(board: widget.board),
            SizedBox(
              width: 20,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      message: const Text(
                        'Sort by',
                      ),
                      actions: [
                        CupertinoActionSheetAction(
                          child: Text(
                            'Image Count',
                            style: boardSort == Sort.byImagesCount
                                ? const TextStyle(fontWeight: FontWeight.w700)
                                : const TextStyle(
                                    fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            setSort(Sort.byImagesCount, settings);
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            'Reply Count',
                            style: boardSort == Sort.byReplyCount
                                ? const TextStyle(fontWeight: FontWeight.w700)
                                : const TextStyle(
                                    fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            setSort(Sort.byReplyCount, settings);
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            'Bump Order',
                            style: boardSort == Sort.byBumpOrder
                                ? const TextStyle(fontWeight: FontWeight.w700)
                                : const TextStyle(
                                    fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            setSort(Sort.byBumpOrder, settings);
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            'Newest',
                            style: boardSort == Sort.byNewest
                                ? const TextStyle(fontWeight: FontWeight.w700)
                                : const TextStyle(
                                    fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            setSort(Sort.byNewest, settings);
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text(
                            'Oldest',
                            style: boardSort == Sort.byOldest
                                ? const TextStyle(fontWeight: FontWeight.w700)
                                : const TextStyle(
                                    fontWeight: FontWeight.normal),
                          ),
                          onPressed: () {
                            setSort(Sort.byOldest, settings);
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
              switch (settings.getBoardView()) {
                case View.listView:
                  return BoardListView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
                  break;
                case View.gridView:
                default:
                  return BoardGridView(
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
