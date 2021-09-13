import 'package:flutter/material.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_html/flutter_html.dart';

class BoardListView extends StatelessWidget {
  BoardListView({
    @required this.board,
    @required this.snapshot,
    @required this.scrollController,
  });

  final String board;
  final AsyncSnapshot<List<Post>> snapshot;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.15,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        post.tim != null
                            ? SizedBox(
                                width: 125,
                                height: 125,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'https://i.4cdn.org/$board/' +
                                          post.tim.toString() +
                                          's.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No.' + post.no.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                post.sub != null
                                    ? Text(
                                        post.sub.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Container(),
                                Text(
                                  'R: ' +
                                      post.replies.toString() +
                                      ' / I: ' +
                                      post.images.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    post.com != null
                        ? Html(
                            data: post.com.toString(),
                          )
                        : Container(),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
