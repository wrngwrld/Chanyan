import 'package:flutter/material.dart';
import 'package:flutter_chan/VideoView.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';

import 'Models/ThreadModel.dart';

class Thread extends StatelessWidget {
  const Thread({
    @required this.board,
    @required this.id,
    @required this.threadName,
  });

  final board;
  final id;
  final threadName;

  Future<ThreadModel> makeGetRequest() async {
    final url = Uri.parse('https://a.4cdn.org/$board/thread/$id.json');
    Response response = await get(url);
    // print('Status code: ${response.statusCode}');
    // print('Headers: ${response.headers}');
    // print('Body: ${response.body}');

    final threadModel = threadModelFromJson(response.body);

    return threadModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(threadName),
      ),
      body: FutureBuilder(
        future: makeGetRequest(),
        builder: (BuildContext context, AsyncSnapshot<ThreadModel> snapshot) {
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
                  for (Post post in snapshot.data.posts)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: .25,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            post.filename != null
                                ? SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 0, 8, 16),
                                      child: InkWell(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VideoView(
                                                video: post.tim.toString() +
                                                    post.ext.toString(),
                                                ext: post.ext.toString(),
                                                board: board,
                                              ),
                                            ),
                                          )
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            'https://i.4cdn.org/$board/' +
                                                post.tim.toString() +
                                                's.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    post.filename != null
                                        ? Text(
                                            post.filename.toString() +
                                                post.ext.toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Container(),
                                    Text(
                                      'No.' + post.no.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    post.com != null
                                        ? Html(
                                            data: post.com.toString(),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}
