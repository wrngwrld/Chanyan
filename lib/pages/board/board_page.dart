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
  final TextEditingController _searchBarController = TextEditingController();

  Future<List<Post>> _fetchAllThreadsFromBoard;

  List<Post> filterdBoards;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _fetchAllThreadsFromBoard =
        fetchAllThreadsFromBoard(settings.getBoardSort(), widget.board)
            .then((value) => filterdBoards = value);
  }

  void setSort(Sort sortBy, SettingsProvider settings) {
    setState(() {
      _searchBarController.clear();

      _fetchAllThreadsFromBoard = fetchAllThreadsFromBoard(sortBy, widget.board)
          .then((value) => filterdBoards = value);
    });
  }

  Widget getBoardView(SettingsProvider settings, List<Post> threads) {
    switch (settings.getBoardView()) {
      case View.listView:
        return BoardListView(
          scrollController: scrollController,
          board: widget.board,
          threads: threads,
        );
        break;
      case View.gridView:
      default:
        return BoardListView(
          scrollController: scrollController,
          board: widget.board,
          threads: threads,
        );
    }
  }

  void _updateThreadsList(String value, List<Post> data) {
    if (value.isNotEmpty) {
      filterdBoards = data
          .where((element) => element.sub != null
              ? element.sub.toLowerCase().contains(value.toLowerCase())
              : false || element.name != null
                  ? element.name.toLowerCase().contains(value.toLowerCase())
                  : false || element.com != null
                      ? element.com.toLowerCase().contains(value.toLowerCase())
                      : false)
          .toList();
    } else {
      _searchBarController.clear();
      filterdBoards = data;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final Sort boardSort = settings.getBoardSort();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CupertinoPageScaffold(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground
            : Colors.black,
        child: Scrollbar(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: theme.getTheme() == ThemeData.light()
                    ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
                    : CupertinoColors.black.withOpacity(0.7),
                largeTitle: MediaQuery(
                  data: MediaQueryData(
                    textScaleFactor: MediaQuery.textScaleFactorOf(context),
                  ),
                  child: Text(
                    '/${widget.board}/ - ${widget.boardName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.getTheme() == ThemeData.dark()
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                ),
                leading: MediaQuery(
                  data: MediaQueryData(
                    textScaleFactor: MediaQuery.textScaleFactorOf(context),
                  ),
                  child: Transform.translate(
                    offset: const Offset(-16, 0),
                    child: CupertinoNavigationBarBackButton(
                      previousPageTitle: 'Home',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
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
                            builder: (BuildContext context) =>
                                CupertinoActionSheet(
                              message: const Text(
                                'Sort by',
                              ),
                              actions: [
                                CupertinoActionSheetAction(
                                  child: Text(
                                    'Image Count',
                                    style: boardSort == Sort.byImagesCount
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w700)
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
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w700)
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
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w700)
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
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w700)
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
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w700)
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
                border: null,
                stretch: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FutureBuilder(
                        future: _fetchAllThreadsFromBoard,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Post>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return SizedBox(
                                height: 400,
                                child: Center(
                                  child: PlatformCircularProgressIndicator(
                                    material: (_, __) =>
                                        MaterialProgressIndicatorData(
                                            color: AppColors.kGreen),
                                  ),
                                ),
                              );
                              break;
                            default:
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: ClipRect(
                                      child: CupertinoSearchTextField(
                                        controller: _searchBarController,
                                        onChanged: (value) {
                                          _updateThreadsList(
                                            value,
                                            snapshot.data,
                                          );
                                        },
                                        onSubmitted: (value) {
                                          _updateThreadsList(
                                            value,
                                            snapshot.data,
                                          );
                                        },
                                        onSuffixTap: () {
                                          _updateThreadsList(
                                            '',
                                            snapshot.data,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  getBoardView(settings, filterdBoards),
                                ],
                              );
                          }
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
