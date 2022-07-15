import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListPost extends StatefulWidget {
  const ListPost({
    Key key,
    @required this.board,
    @required this.post,
  }) : super(key: key);

  final String board;
  final Post post;

  @override
  State<ListPost> createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
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
      imageUrl: '${widget.post.tim}s.jpg',
      board: widget.board,
    );

    favoriteString = json.encode(favorite);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final bookmarks = Provider.of<BookmarksProvider>(context);

    isFavorite = bookmarks.getBookmarks().contains(favoriteString);

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: [
        if (isFavorite)
          IconSlideAction(
            caption: 'Remove',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => {
              bookmarks.removeBookmarks(favorite),
            },
          )
        else
          IconSlideAction(
            caption: 'Add',
            color: Colors.green,
            icon: Icons.add,
            onTap: () => {
              bookmarks.addBookmarks(favorite),
            },
          )
      ],
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadPage(
                threadName: widget.post.sub ?? widget.post.com,
                thread: widget.post.no,
                post: widget.post,
                board: widget.board,
              ),
            ),
          )
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          decoration: const BoxDecoration(
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
                  if (widget.post.tim != null)
                    SizedBox(
                      width: 125,
                      height: 125,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://i.4cdn.org/${widget.board}/${widget.post.tim}s.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No.${widget.post.no}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.post.sub != null)
                            Text(
                              unescape(cleanTags(widget.post.sub)),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.getTheme() == ThemeData.dark()
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )
                          else
                            Container(),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.reply,
                                color: Colors.white,
                                size: 12,
                              ),
                              Text(
                                ' ${widget.post.replies}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                CupertinoIcons.camera,
                                color: Colors.white,
                                size: 12,
                              ),
                              Text(
                                ' ${widget.post.images}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('kk:mm - dd.MM.y').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                widget.post.tim,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.post.com != null)
                Html(
                  data: widget.post.com,
                  style: {
                    'body': Style(
                      color: theme.getTheme() == ThemeData.dark()
                          ? Colors.white
                          : Colors.black,
                    ),
                  },
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
