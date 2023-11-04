import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/archived.dart';
import 'package:flutter_chan/Models/bookmark.dart';
import 'package:flutter_chan/Models/bookmark_status.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/pages/replies_row.dart';
import 'package:flutter_chan/pages/thread/thread_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_chan/widgets/image_viewer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BookmarksPost extends StatefulWidget {
  const BookmarksPost({
    Key? key,
    required this.favorite,
  }) : super(key: key);

  final Bookmark favorite;

  @override
  State<BookmarksPost> createState() => _BookmarksPostState();
}

class _BookmarksPostState extends State<BookmarksPost> {
  bool isDeleted = false;

  late Future<BookmarkStatus> _fetchBookmarkStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final bookmarks = Provider.of<BookmarksProvider>(context);

    _fetchBookmarkStatus = fetchBookmarkStatus(
        widget.favorite.board, widget.favorite.no.toString());

    return FutureBuilder<BookmarkStatus>(
        future: _fetchBookmarkStatus,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return createBookmarkPost(
                ThreadStatus.online,
                null,
                theme,
              );
            default:
              if (snapshot.data!.status == ThreadStatus.deleted) {
                isDeleted = true;
              }
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.3,
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      label: 'Delete',
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      onPressed: (context) => {
                        bookmarks.removeBookmarks(
                          widget.favorite,
                        ),
                      },
                    )
                  ],
                ),
                child: InkWell(
                  onTap: () => {
                    if (!isDeleted)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ThreadPage(
                            post: Post(
                              no: widget.favorite.no,
                              sub: widget.favorite.sub,
                              com: widget.favorite.com,
                              tim: int.parse(
                                widget.favorite.imageUrl!.substring(
                                    0, widget.favorite.imageUrl!.length - 5),
                              ),
                              board: widget.favorite.board,
                            ),
                            threadName: widget.favorite.sub ??
                                widget.favorite.com ??
                                'No.${widget.favorite.no}',
                            thread: widget.favorite.no ?? 0,
                            board: widget.favorite.board ?? '',
                            fromFavorites: true,
                          ),
                        ),
                      )
                  },
                  child: createBookmarkPost(
                      snapshot.data!.status, snapshot.data!.replies, theme),
                ),
              );
          }
        });
  }

  Container createBookmarkPost(
    ThreadStatus? status,
    ThreadReplyCount? replyCount,
    ThemeChanger theme,
  ) {
    return Container(
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
                        child: ImageViewer(
                          url:
                              'https://i.4cdn.org/${widget.favorite.board}/${widget.favorite.imageUrl}',
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (status == ThreadStatus.archived)
                        const Text(
                          'archived',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        )
                      else if (status == ThreadStatus.deleted)
                        const Text(
                          'deleted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
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
                          unescape(cleanTags(widget.favorite.sub ?? '')),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.getTheme() == ThemeData.dark()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      if (isDeleted ||
                          replyCount == null ||
                          replyCount.replies == null)
                        const RepliesRow()
                      else
                        RepliesRow(
                          replies: replyCount.replies,
                          imageReplies: replyCount.images,
                        ),
                    ],
                  ),
                ),
              )
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
        ],
      ),
    );
  }
}
