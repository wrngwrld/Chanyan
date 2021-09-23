import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/favorites.dart';
import 'package:flutter_chan/Models/favorite.dart';

class BookmarkButton extends StatefulWidget {
  BookmarkButton({
    this.favorite,
  });

  final Favorite favorite;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    isBookmarkCheck(widget.favorite).then((value) {
      setState(() {
        isFavorite = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => {
              isFavorite
                  ? removeBookmark(widget.favorite)
                  : addBookmark(widget.favorite),
              isFavorite
                  ? setState(() {
                      isFavorite = false;
                    })
                  : setState(() {
                      isFavorite = true;
                    }),
            },
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
              color: CupertinoColors.systemRed,
            ),
          )
        : IconButton(
            onPressed: () => {
              isFavorite
                  ? removeBookmark(widget.favorite)
                  : addBookmark(widget.favorite),
              isFavorite
                  ? setState(() {
                      isFavorite = false;
                    })
                  : setState(() {
                      isFavorite = true;
                    }),
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
            ),
          );
  }
}
