import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/board_list_favorites.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/models/board.dart';
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

    setState(() {
      favoriteBoards = prefs.getStringList('favoriteBoards');
    });
  }

  reload() {
    setState(() {});
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
              backgroundColor: CupertinoColors.white.withOpacity(0.85),
              middle: Text('Chanyan'),
              trailing: SizedBox(
                width: 20,
                child: CupertinoButton(
                  onPressed: () => {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => BoardListFavorites()),
                        )
                        .then((value) => onGoBack())
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.star_outline,
                    color: CupertinoColors.systemYellow,
                  ),
                ),
              ),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text('Chanyan'),
              actions: [
                IconButton(
                  onPressed: () => {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => BoardListFavorites()),
                        )
                        .then((value) => onGoBack())
                  },
                  icon: Icon(Icons.star),
                ),
              ],
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
              return favoriteBoards.length == 0
                  ? Center(
                      child: Text(
                        'Add your boards first!',
                        style: TextStyle(
                          fontSize: 26,
                        ),
                      ),
                    )
                  : Scrollbar(
                      child: ListView(
                        children: [
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
                                  setState(() {
                                    removeFromFavorites(board);
                                  });
                                },
                                child: InkWell(
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BoardPage(
                                          boardName: board.title,
                                          board: board.board,
                                        ),
                                      ),
                                    ),
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 0, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '/' + board.board + '/',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                board.title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
