import 'package:flutter/cupertino.dart';

class RepliesRow extends StatelessWidget {
  const RepliesRow({
    Key key,
    this.replies = '-',
    this.imageReplies = '-',
    this.showImageReplies = true,
  }) : super(key: key);

  final replies;
  final imageReplies;
  final bool showImageReplies;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.reply,
          color: CupertinoColors.white,
          size: 13,
        ),
        Text(
          ' $replies',
          style: const TextStyle(
            color: CupertinoColors.white,
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
              const Icon(
                CupertinoIcons.camera,
                color: CupertinoColors.white,
                size: 13,
              ),
              Text(
                ' $imageReplies',
                style: const TextStyle(
                  color: CupertinoColors.white,
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
