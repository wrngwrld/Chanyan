import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/favoriteModel.dart';
import 'package:flutter_chan/constants.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({@required this.board});

  final String board;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteProvider>(context);

    isFavorite = favorites.getFavorites().contains(widget.board);

    return Platform.isIOS
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              isFavorite
                  ? favorites.removeFavorites(widget.board)
                  : favorites.addFavorites(widget.board);
            },
            child: Icon(
              isFavorite ? Icons.star_rate : Icons.star_outline,
              color: CupertinoColors.systemYellow,
            ),
          )
        : IconButton(
            onPressed: () {
              isFavorite
                  ? favorites.removeFavorites(widget.board)
                  : favorites.addFavorites(widget.board);
            },
            icon: Icon(
              isFavorite ? Icons.star_rate : Icons.star_outline,
              color: AppColors.kWhite,
            ),
          );
  }
}
