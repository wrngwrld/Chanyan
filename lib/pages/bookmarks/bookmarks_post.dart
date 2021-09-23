import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/archived.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookmarksPost extends StatefulWidget {
  const BookmarksPost({@required this.favorite});

  final Favorite favorite;

  @override
  State<BookmarksPost> createState() => _BookmarksPostState();
}

class _BookmarksPostState extends State<BookmarksPost> {
  refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            removeFavorite(widget.favorite);
          },
        ),
      ],
      child: InkWell(
        onTap: () => {
          Navigator.of(context)
              .push(
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
                    threadName: widget.favorite.sub != null
                        ? widget.favorite.sub.toString()
                        : widget.favorite.com.toString(),
                    thread: widget.favorite.no,
                    board: widget.favorite.board,
                    fromFavorites: true,
                  ),
                ),
              )
              .then((value) => {refreshPage()})
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.getTheme() == ThemeData.dark()
                    ? CupertinoColors.systemGrey
                    : Color(0x1F000000),
                width: 0.15,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.favorite.imageUrl != null
                      ? SizedBox(
                          width: 125,
                          height: 125,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'https://i.4cdn.org/${widget.favorite.board}/' +
                                    widget.favorite.imageUrl,
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
                          FutureBuilder(
                              future: fetchArchived(widget.favorite.board,
                                  widget.favorite.no.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<ThreadStatus> snapshot2) {
                                switch (snapshot2.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container();
                                    break;
                                  default:
                                    switch (snapshot2.data) {
                                      case ThreadStatus.archived:
                                        Text(
                                          'archived',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        );
                                        break;
                                      case ThreadStatus.deleted:
                                        Text(
                                          'deleted',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        );
                                        break;
                                      case ThreadStatus.online:
                                        Container();
                                        break;
                                      default:
                                        Container();
                                    }
                                    return snapshot2.data ==
                                            ThreadStatus.archived
                                        ? Text(
                                            'archived',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                          )
                                        : Container();
                                }
                              }),
                          Text(
                            'No.' + widget.favorite.no.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          widget.favorite.sub != null
                              ? Text(
                                  Stringz.unescape(Stringz.cleanTags(
                                      widget.favorite.sub.toString())),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                )
                              : Container(),
                          FutureBuilder(
                            future: fetchReplies(widget.favorite.board,
                                widget.favorite.no.toString()),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<int>> snapshot3) {
                              switch (snapshot3.connectionState) {
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
                                  return Text(
                                    'R: ' +
                                        snapshot3.data[0].toString() +
                                        ' / I: ' +
                                        snapshot3.data[1].toString(),
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
              widget.favorite.com != null
                  ? Html(
                      data: widget.favorite.com.toString(),
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
