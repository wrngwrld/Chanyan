import 'package:flutter/material.dart';
import 'package:flutter_chan/API/favorites.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ListPost extends StatefulWidget {
  const ListPost({
    @required this.board,
    @required this.post,
  });

  final String board;
  final Post post;

  @override
  State<ListPost> createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
  Favorite favorite;
  bool isFavorite = false;

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

    isBookmarkCheck(favorite).then((value) {
      setState(() {
        isFavorite = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        isFavorite
            ? IconSlideAction(
                caption: 'Remove',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => {
                  removeBookmark(favorite),
                  if (mounted)
                    setState(() {
                      isFavorite = false;
                    }),
                },
              )
            : IconSlideAction(
                caption: 'Add',
                color: Colors.green,
                icon: Icons.add,
                onTap: () => {
                  addBookmark(favorite),
                  if (mounted)
                    setState(() {
                      isFavorite = true;
                    }),
                },
              ),
      ],
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadPage(
                threadName: widget.post.sub != null
                    ? widget.post.sub.toString()
                    : widget.post.com.toString(),
                thread: widget.post.no,
                post: widget.post,
                board: widget.board,
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
                  widget.post.tim != null
                      ? SizedBox(
                          width: 125,
                          height: 125,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'https://i.4cdn.org/${widget.board}/' +
                                    widget.post.tim.toString() +
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
                            'No.' + widget.post.no.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          widget.post.sub != null
                              ? Text(
                                  Stringz.unescape(Stringz.cleanTags(
                                      widget.post.sub.toString())),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                )
                              : Container(),
                          Text(
                            'R: ' +
                                widget.post.replies.toString() +
                                ' / I: ' +
                                widget.post.images.toString(),
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
              widget.post.com != null
                  ? Html(
                      data: widget.post.com.toString(),
                      style: {
                        "body": Style(
                          color: theme.getTheme() == ThemeData.dark()
                              ? Colors.white
                              : Colors.black,
                        ),
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
