import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/bookmarksModel.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class GridPost extends StatefulWidget {
  const GridPost({
    @required this.board,
    @required this.post,
  });

  final String board;
  final Post post;

  @override
  State<GridPost> createState() => _GridPostState();
}

class _GridPostState extends State<GridPost> {
  Favorite favorite;
  bool isFavorite = false;
  String favoriteString;

  @override
  void initState() {
    super.initState();

    favorite = Favorite(
      no: widget.post.no,
      sub: widget.post.sub,
      com: widget.post.com,
      imageUrl: widget.post.tim.toString() + 's.jpg',
      board: widget.board.toString(),
    );

    favoriteString = json.encode(favorite);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<BookmarksProvider>(context);

    isFavorite = bookmarks.getBookmarks().contains(favoriteString);

    return InkWell(
      onLongPress: () => {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: [
              isFavorite
                  ? CupertinoActionSheetAction(
                      child: Text('Remove bookmark'),
                      onPressed: () {
                        bookmarks.removeBookmarks(favorite);

                        setState(() {
                          isFavorite = false;
                        });

                        Navigator.pop(context);
                      },
                    )
                  : CupertinoActionSheetAction(
                      child: Text('Set bookmark'),
                      onPressed: () {
                        bookmarks.addBookmarks(favorite);

                        setState(() {
                          isFavorite = true;
                        });

                        Navigator.pop(context);
                      },
                    ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        )
      },
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ThreadPage(
              threadName: widget.post.sub != null
                  ? widget.post.sub.toString()
                  : widget.post.com.toString(),
              thread: widget.post.no,
              board: widget.board,
              post: widget.post,
            ),
          ),
        )
      },
      child: Stack(
        children: [
          Image.network(
            'https://i.4cdn.org/${widget.board}/' +
                widget.post.tim.toString() +
                's.jpg',
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
                    widget.post.sub != null
                        ? Html(
                            data: widget.post.sub,
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
                            data: widget.post.com ?? '',
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
                            widget.post.replies.toString() +
                            ' / I: ' +
                            widget.post.images.toString(),
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
    );
  }
}
