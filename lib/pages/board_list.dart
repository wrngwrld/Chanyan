import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/pages/board_list_favorites.dart';
import 'package:flutter_chan/pages/board_page.dart';
import 'package:flutter_chan/models/board.dart';
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

    print(favoriteBoards);
  }

  onGoBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
      appBar: AppBar(
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
        future: fetchBoards(),
        builder: (BuildContext context, AsyncSnapshot<List<Board>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.green,
              );
              break;
            default:
              return ListView(
                children: [
                  for (Board board in snapshot.data)
                    if (favoriteBoards.contains(board.board))
                      InkWell(
                        onTap: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BoardPage(
                                board: board.board,
                                name: board.board,
                              ),
                            ),
                          ),
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
                          ],
                        ),
                      )
                ],
              );
          }
        },
      ),
    );
  }
}
