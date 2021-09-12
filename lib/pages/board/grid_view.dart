import 'package:flutter/material.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_html/flutter_html.dart';

class BoardGridView extends StatelessWidget {
  BoardGridView({
    @required this.board,
    @required this.snapshot,
  });

  final String board;
  final AsyncSnapshot<List<Post>> snapshot;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        for (Post post in snapshot.data)
          InkWell(
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThreadPage(
                    threadName: post.sub != null
                        ? post.sub.toString()
                        : post.com.toString(),
                    thread: post.no,
                    board: board,
                  ),
                ),
              )
            },
            child: Stack(
              children: [
                Image.network(
                  'https://i.4cdn.org/$board/' + post.tim.toString() + 's.jpg',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.black.withOpacity(0.5),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          post.sub != null
                              ? Html(
                                  data: post.sub,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16.0),
                                      color: Colors.white,
                                      maxLines: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  },
                                )
                              : Html(
                                  data: post.com,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16.0),
                                      color: Colors.white,
                                      maxLines: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  },
                                ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'R: ' +
                                  post.replies.toString() +
                                  ' / I: ' +
                                  post.images.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
