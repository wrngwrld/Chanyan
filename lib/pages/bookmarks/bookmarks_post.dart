import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/archived.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BookmarksPost extends StatefulWidget {
  const BookmarksPost({
    Key key,
    @required this.favorite,
  }) : super(key: key);

  final Favorite favorite;

  @override
  State<BookmarksPost> createState() => _BookmarksPostState();
}

class _BookmarksPostState extends State<BookmarksPost> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final bookmarks = Provider.of<BookmarksProvider>(context);

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            bookmarks.removeBookmarks(widget.favorite);
          },
        ),
      ],
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadPage(
                post: Post(
                  no: widget.favorite.no,
                  sub: widget.favorite.sub,
                  com: widget.favorite.com,
                  tim: int.parse(
                    widget.favorite.imageUrl
                        .substring(0, widget.favorite.imageUrl.length - 5),
                  ),
                  board: widget.favorite.board,
                ),
                threadName: widget.favorite.sub ?? widget.favorite.com,
                thread: widget.favorite.no,
                board: widget.favorite.board,
                fromFavorites: true,
              ),
            ),
          )
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.getTheme() == ThemeData.dark()
                    ? CupertinoColors.systemGrey
                    : const Color(0x1F000000),
                width: 0.15,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.favorite.imageUrl != null)
                    SizedBox(
                      width: 125,
                      height: 125,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://i.4cdn.org/${widget.favorite.board}/${widget.favorite.imageUrl}',
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
                          FutureBuilder<ThreadStatus>(
                              future: fetchArchived(widget.favorite.board,
                                  widget.favorite.no.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<ThreadStatus> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container();
                                    break;
                                  default:
                                    switch (snapshot.data) {
                                      case ThreadStatus.archived:
                                        return const Text(
                                          'archived',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        );
                                        break;
                                      case ThreadStatus.deleted:
                                        return const Text(
                                          'deleted',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        );
                                        break;
                                      case ThreadStatus.online:
                                        return Container();
                                        break;
                                      default:
                                        return Container();
                                    }
                                }
                              }),
                          Text(
                            'No.${widget.favorite.no}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.favorite.sub != null)
                            Text(
                              unescape(cleanTags(widget.favorite.sub)),
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
                          FutureBuilder<List<int>>(
                            future: fetchReplies(widget.favorite.board,
                                widget.favorite.no.toString()),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<int>> snapshot1) {
                              switch (snapshot1.connectionState) {
                                case ConnectionState.waiting:
                                  return Text(
                                    'R: - / I: -',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          theme.getTheme() == ThemeData.dark()
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  );
                                  break;
                                default:
                                  if (snapshot1.data == null)
                                    return Text(
                                      'R: - / I: -',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.getTheme() == ThemeData.dark()
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    );
                                  return Text(
                                    'R:${snapshot1.data[0]} / I: ${snapshot1.data[1]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          theme.getTheme() == ThemeData.dark()
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.favorite.com != null)
                Html(
                  data: widget.favorite.com,
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
