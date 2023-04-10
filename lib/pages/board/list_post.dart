import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/replies_row.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListPost extends StatefulWidget {
  const ListPost({
    Key? key,
    required this.board,
    required this.post,
  }) : super(key: key);

  final String board;
  final Post post;

  @override
  State<ListPost> createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
  late Favorite favorite;
  bool isFavorite = false;
  late String favoriteString;

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
      endActionPane: isFavorite
          ? ActionPane(
              extentRatio: 0.3,
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  label: 'Remove',
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  onPressed: (context) => {
                    bookmarks.removeBookmarks(favorite),
                  },
                )
              ],
            )
          : ActionPane(
              extentRatio: 0.3,
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  label: 'Add',
                  backgroundColor: Colors.green,
                  icon: Icons.add,
                  onPressed: (context) => {
                    bookmarks.addBookmarks(favorite),
                  },
                )
              ],
            ),
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadPage(
                threadName: widget.post.sub ?? widget.post.com ?? '',
                thread: widget.post.no ?? 0,
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
                              unescape(cleanTags(widget.post.sub ?? '')),
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
                          RepliesRow(
                            replies: widget.post.replies,
                            imageReplies: widget.post.images,
                          ),
                          Text(
                            DateFormat('kk:mm - dd.MM.y').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                widget.post.tim ?? 0,
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
