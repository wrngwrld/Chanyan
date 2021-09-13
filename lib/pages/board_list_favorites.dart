import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardListFavorites extends StatefulWidget {
  @override
  _BoardListFavoritesState createState() => _BoardListFavoritesState();
}

class _BoardListFavoritesState extends State<BoardListFavorites> {
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
        title: Text('Favorites'),
      ),
      body: FutureBuilder(
        future: fetchBoards(),
        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: AppColors.kWhite,
                backgroundColor: AppColors.kGreen,
              );
              break;
            default:
              return Scrollbar(
                child: ListView(
                  children: [
                    for (Board board in snapshot.data)
                      InkWell(
                        onTap: () => {
                          favoriteBoards.contains(board.board)
                              ? removeFromFavorites(board)
                              : addToFavorites(board),
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            IconButton(
                              onPressed: () =>
                                  favoriteBoards.contains(board.board)
                                      ? removeFromFavorites(board)
                                      : addToFavorites(board),
                              icon: Icon(
                                favoriteBoards.contains(board.board)
                                    ? Icons.star_rate
                                    : Icons.star_outline,
                                color: AppColors.kBlack,
                              ),
                            )
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
