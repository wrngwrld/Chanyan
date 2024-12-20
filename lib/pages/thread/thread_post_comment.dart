import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/thread/thread_replied_to.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';

class ThreadPostComment extends StatelessWidget {
  const ThreadPostComment({
    Key? key,
    required this.com,
    required this.thread,
    required this.board,
    required this.allPosts,
  }) : super(key: key);

  final String com;
  final int thread;
  final String board;
  final List<Post> allPosts;

  List<Widget> formatComment(
    String com,
    ThemeChanger theme,
    BuildContext context,
  ) {
    final List<Widget> formattedCom = [];

    final List<String> splittedCom = com.split('<br>');

    for (final line in splittedCom) {
      if (line.startsWith('<a href')) {
        final document = parse(line);

        final urlNo = document.body!.text.replaceFirst('>>', '');

        formattedCom.add(
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThreadRepliesTo(
                    post: int.parse(urlNo),
                    thread: thread,
                    board: board,
                    allPosts: allPosts,
                  ),
                ),
              );
            },
            child: Text(
              '>> $urlNo',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        );
      } else {
        formattedCom.add(
          SelectableText(
            unescape(cleanTags(line)),
            style: TextStyle(
              color: theme.getTheme() == ThemeData.dark()
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        );
      }
    }

    return formattedCom;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    final List<Widget> listCom = formatComment(com, theme, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final Widget comments in listCom) comments,
      ],
    );
  }
}
