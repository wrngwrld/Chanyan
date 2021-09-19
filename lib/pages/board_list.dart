import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
  }

  @override
  void initState() {
    super.initState();

    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              middle: Text('Chanyan'),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text('Chanyan'),
            ),
      body: FutureBuilder(
        future: fetchAllBoards(),
        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
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
              return Scrollbar(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        'favorites',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    for (Board board in snapshot.data)
                      if (favoriteBoards.contains(board.board))
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
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            removeFromFavorites(board);
                          },
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) => BoardPage(
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
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '/' +
                                                  board.board +
                                                  '/  -  ' +
                                                  board.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: Platform.isIOS
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
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
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.kBlack,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        'all',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    for (Board board in snapshot.data)
                      Dismissible(
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerRight,
                          color: Colors.green,
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Expanded(child: Container()),
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          setState(() {
                            addToFavorites(board);
                          });
                        },
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => BoardPage(
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            Stringz.cleanTags(Stringz.unescape(
                                              board.metaDescription,
                                            )),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.kBlack,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
