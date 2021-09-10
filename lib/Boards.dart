import 'package:flutter/material.dart';
import 'package:flutter_chan/Catalog.dart';
import 'package:flutter_chan/Models/BoardModel.dart';
import 'package:http/http.dart';

class Boards extends StatelessWidget {
  const Boards({
    @required this.id,
    @required this.name,
  });

  final id;
  final name;

  Future<BoardModel> makeGetRequest() async {
    final url = Uri.parse('https://a.4cdn.org/boards.json');
    Response response = await get(url);
    // print('Status code: ${response.statusCode}');
    // print('Headers: ${response.headers}');
    // print('Body: ${response.body}');

    final boards = boardModelFromJson(response.body);

    return boards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chanyan'),
      ),
      body: FutureBuilder(
        future: makeGetRequest(),
        builder: (BuildContext context, AsyncSnapshot<BoardModel> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.green,
              );
              break;
            default:
              return Padding(
                padding: EdgeInsets.all(10),
                child: ListView(children: [
                  for (Board board in snapshot.data.boards)
                    InkWell(
                      onTap: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Catalog(
                              id: board.board,
                              name: board.board,
                            ),
                          ),
                        ),
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        child: Text(
                          '/' + board.board + '/',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    )
                ]),
              );
          }
        },
      ),
    );
  }
}
