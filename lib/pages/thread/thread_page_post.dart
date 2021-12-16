import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:flutter_chan/pages/thread/thread_post_comment.dart';
import 'package:flutter_chan/pages/thread/thread_replies.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ThreadPagePost extends StatelessWidget {
  const ThreadPagePost({
    Key key,
    @required this.board,
    @required this.post,
    @required this.thread,
    @required this.names,
    @required this.fileNames,
    @required this.media,
  }) : super(key: key);

  final String board;
  final int thread;
  final Post post;
  final List<String> names;
  final List<String> fileNames;
  final List<Widget> media;

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.systemGrey.withOpacity(0.5)
                  : const Color(0x1F000000),
              width: .25,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.filename != null)
                  SizedBox(
                    width: 125,
                    height: 125,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      child: InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaPage(
                                video: post.tim.toString() + post.ext,
                                ext: post.ext,
                                board: board,
                                height: post.h,
                                width: post.w,
                                names: names,
                                list: media,
                                fileNames: fileNames,
                              ),
                            ),
                          )
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://i.4cdn.org/$board/${post.tim}s.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.filename != null)
                        Text(
                          '${post.ext} (${formatBytes(
                            post.fsize,
                            0,
                          )})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Platform.isIOS
                                ? CupertinoColors.activeBlue
                                : AppColors.kGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Container(),
                      if (post.sub != null)
                        Text(
                          unescape(cleanTags(post.sub)),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.getTheme() == ThemeData.dark()
                                ? Colors.white
                                : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Container(),
                      Text(
                        'No.${post.no}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.getTheme() == ThemeData.dark()
                              ? Colors.white
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        post.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.getTheme() == ThemeData.dark()
                              ? Colors.white
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('kk:mm - dd.MM.y').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            post.time * 1000,
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
                const Divider(
                  height: 20,
                ),
              ],
            ),
            if (post.com != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ThreadPostComment(
                  com: post.com,
                  board: board,
                  thread: thread,
                ),
              )
            else
              Container(),
            FutureBuilder(
              future: fetchAllRepliesToPost(
                post.no,
                board,
                thread,
              ),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text(
                      'Replies: loading...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.getTheme() == ThemeData.dark()
                            ? Colors.white
                            : Colors.black,
                      ),
                    );
                    break;
                  default:
                    if (snapshot.data.isNotEmpty)
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ThreadReplies(
                                replies: snapshot.data,
                                post: post,
                                thread: thread,
                                board: board,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Replies: ${snapshot.data.length} ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.getTheme() == ThemeData.dark()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    else
                      return Text(
                        '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.getTheme() == ThemeData.dark()
                              ? Colors.white
                              : Colors.black,
                        ),
                      );
                }
              },
            ),
            const Divider(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
