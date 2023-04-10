import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:provider/provider.dart';

class RepliesRow extends StatelessWidget {
  const RepliesRow({
    Key? key,
    this.replies = '-',
    this.imageReplies = '-',
    this.showImageReplies = true,
    this.invertTextColor = false,
  }) : super(key: key);

  final replies;
  final imageReplies;
  final bool showImageReplies;
  final bool invertTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    final darkColor = invertTextColor
        ? theme.getTheme() == ThemeData.dark()
        : theme.getTheme() != ThemeData.dark();

    return Row(
      children: [
        Icon(
          CupertinoIcons.reply,
          color: darkColor ? CupertinoColors.black : CupertinoColors.white,
          size: 13,
        ),
        Text(
          ' $replies',
          style: TextStyle(
            color: darkColor ? CupertinoColors.black : CupertinoColors.white,
            fontSize: 13,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        if (showImageReplies)
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                CupertinoIcons.camera,
                color:
                    darkColor ? CupertinoColors.black : CupertinoColors.white,
                size: 13,
              ),
              Text(
                ' $imageReplies',
                style: TextStyle(
                  color:
                      darkColor ? CupertinoColors.black : CupertinoColors.white,
                  fontSize: 13,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
      ],
    );
  }
}
