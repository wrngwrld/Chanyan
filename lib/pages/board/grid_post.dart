import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/bookmark.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/replies_row.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/widgets/image_viewer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class GridPost extends StatefulWidget {
  const GridPost({
    Key? key,
    required this.board,
    required this.post,
  }) : super(key: key);

  final String board;
  final Post post;

  @override
  State<GridPost> createState() => _GridPostState();
}

class _GridPostState extends State<GridPost> {
  late Bookmark favorite;
  bool isFavorite = false;
  late String favoriteString;

  @override
  void initState() {
    super.initState();

    favorite = Bookmark(
      no: widget.post.no,
      sub: widget.post.sub,
      com: widget.post.com,
      imageUrl: '${widget.post.tim}s.jpg',
      board: widget.board,
    );

    favoriteString = json.encode(favorite);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<BookmarksProvider>(context);
    final theme = Provider.of<ThemeChanger>(context);

    isFavorite = bookmarks.getBookmarks().contains(favoriteString);

    return InkWell(
      onLongPress: () => {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: [
              if (isFavorite)
                CupertinoActionSheetAction(
                  child: const Text('Remove bookmark'),
                  onPressed: () {
                    bookmarks.removeBookmarks(favorite);

                    Navigator.pop(context);
                  },
                )
              else
                CupertinoActionSheetAction(
                  child: const Text('Set bookmark'),
                  onPressed: () {
                    bookmarks.addBookmarks(favorite);

                    Navigator.pop(context);
                  },
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('Cancel'),
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
              threadName: widget.post.sub ?? widget.post.com ?? '',
              thread: widget.post.no ?? 0,
              board: widget.board,
              post: widget.post,
            ),
          ),
        )
      },
      child: Stack(
        children: [
          ImageViewer(
            url: 'https://i.4cdn.org/${widget.board}/${widget.post.tim}s.jpg',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.post.sub != null)
                      Html(
                        data: widget.post.sub,
                        style: {
                          'body': Style(
                            fontSize: FontSize(16.0),
                            color: Colors.white,
                            maxLines: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        },
                      )
                    else
                      Html(
                        data: widget.post.com ?? '',
                        style: {
                          'body': Style(
                            fontSize: FontSize(16.0),
                            color: Colors.white,
                            maxLines: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RepliesRow(
                              replies: widget.post.replies,
                              imageReplies: widget.post.images,
                              invertTextColor:
                                  !!(theme.getTheme() != ThemeData.dark())),
                          GestureDetector(
                            onTap: () => {
                              if (isFavorite)
                                bookmarks.removeBookmarks(favorite)
                              else
                                bookmarks.addBookmarks(favorite),
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: CupertinoColors.systemRed,
                            ),
                          )
                        ],
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
