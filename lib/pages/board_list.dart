import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardList extends StatefulWidget {
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  List<String> favoriteBoards = [];

  addToFavorites(Board board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

    if (favoriteBoardsPref == null) favoriteBoardsPref = [];

    if (!favoriteBoardsPref.contains(board.board))
      favoriteBoardsPref.add(board.board);

    setState(() {
      favoriteBoards = favoriteBoardsPref;
    });

    prefs.setStringList('favoriteBoards', favoriteBoardsPref);
  }

  removeFromFavorites(Board board) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteBoardsPref = prefs.getStringList('favoriteBoards');

    favoriteBoardsPref.remove(board.board);

    setState(() {
      favoriteBoards = favoriteBoardsPref;
    });

    prefs.setStringList('favoriteBoards', favoriteBoardsPref);
  }

  fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    favoriteBoards = prefs.getStringList('favoriteBoards');

    if (favoriteBoards == null) favoriteBoards = [];
  }

  onGoBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      favoriteBoards = prefs.getStringList('favoriteBoards');
    });

    if (favoriteBoards == null) favoriteBoards = [];
  }

  @override
  void initState() {
    super.initState();

    fetchFavorites();
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
                      '4chan',
                    ),
                    backgroundColor: theme.getTheme() == ThemeData.dark()
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => {
                        theme.setTheme(
                          theme.getTheme() == ThemeData.dark()
                              ? ThemeData.light()
                              : ThemeData.dark(),
                        )
                      },
                      child: Icon(Icons.dark_mode_outlined),
                    ),
                  )
                : SliverAppBar(
                    backgroundColor: AppColors.kGreen,
                    foregroundColor: AppColors.kWhite,
                    title: Text(
                      'Chanyan',
                    ),
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
                    future: fetchAllBoards(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Board>> snapshot) {
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5, 10, 5, 10),
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
                                if (favoriteBoards.contains(board.board))
                                  Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => {
                                          removeFromFavorites(board),
                                        },
                                      ),
                                    ],
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () => {
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BoardPage(
                                                      boardName: board.title,
                                                      board: board.board,
                                                    ),
                                                  ),
                                                )
                                                .then((value) => onGoBack())
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '/' +
                                                            board.board +
                                                            '/  -  ' +
                                                            board.title,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: Platform
                                                                  .isIOS
                                                              ? FontWeight.w700
                                                              : FontWeight.w600,
                                                          color:
                                                              theme.getTheme() ==
                                                                      ThemeData
                                                                          .dark()
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        Stringz.cleanTags(
                                                            Stringz.unescape(
                                                          board.metaDescription,
                                                        )),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              theme.getTheme() ==
                                                                      ThemeData
                                                                          .dark()
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              )
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          color: theme.getTheme() ==
                                                  ThemeData.dark()
                                              ? Color(0x1FFFFFFF)
                                              : Color(0x1F000000),
                                          indent: 5,
                                          endIndent: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5, 10, 5, 10),
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
                                Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'Add',
                                      color: Colors.green,
                                      icon: Icons.add,
                                      onTap: () => {
                                        addToFavorites(board),
                                      },
                                    ),
                                  ],
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () => {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BoardPage(
                                                    boardName: board.title,
                                                    board: board.board,
                                                  ),
                                                ),
                                              )
                                              .then((value) => onGoBack()),
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '/' +
                                                          board.board +
                                                          '/  -  ' +
                                                          board.title,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            theme.getTheme() ==
                                                                    ThemeData
                                                                        .dark()
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      Stringz.cleanTags(
                                                          Stringz.unescape(
                                                        board.metaDescription,
                                                      )),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            theme.getTheme() ==
                                                                    ThemeData
                                                                        .dark()
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            )
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color:
                                            theme.getTheme() == ThemeData.dark()
                                                ? Color(0x1FFFFFFF)
                                                : Color(0x1F000000),
                                        indent: 5,
                                        endIndent: 5,
                                      ),
                                    ],
                                  ),
                                ),
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
