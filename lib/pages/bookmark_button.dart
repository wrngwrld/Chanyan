import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/favorite.dart';
import 'package:flutter_chan/blocs/bookmarks_model.dart';
import 'package:provider/provider.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    Key? key,
    this.favorite,
  }) : super(key: key);

  final Favorite? favorite;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isFavorite = false;
  late String favoriteString;

  @override
  void initState() {
    super.initState();

    favoriteString = json.encode(widget.favorite);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<BookmarksProvider>(context);

    isFavorite = bookmarks.getBookmarks().contains(favoriteString);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => {
        if (isFavorite)
          bookmarks.removeBookmarks(widget.favorite)
        else
          bookmarks.addBookmarks(widget.favorite),
      },
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
        color: CupertinoColors.systemRed,
      ),
    );
  }
}
