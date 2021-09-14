import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/board_list_favorites.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardList extends StatefulWidget {
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  List<String> favoriteBoards = [];
  Offset _tapDownPosition;

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
      appBar: AppBar(
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
            icon: Icon(Icons.star_rate),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchAllBoards(),
        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: AppColors.kWhite,
                backgroundColor: AppColors.kGreen,
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
                              InkWell(
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
                                onTapDown: (TapDownDetails details) {
                                  _tapDownPosition = details.globalPosition;
                                },
                                onLongPress: () async {
                                  RenderBox overlay = Overlay.of(context)
                                      .context
                                      .findRenderObject();

                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      _tapDownPosition.dx,
                                      _tapDownPosition.dy,
                                      overlay.size.width - _tapDownPosition.dx,
                                      overlay.size.height - _tapDownPosition.dy,
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        value: 'remove',
                                        child: Text('Remove from favorites'),
                                        onTap: () => {
                                          removeFromFavorites(board),
                                          reload(),
                                        },
                                      ),
                                    ],
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 10),
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
