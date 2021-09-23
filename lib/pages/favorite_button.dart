import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/favorites.dart';
import 'package:flutter_chan/constants.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({@required this.board});

  final String board;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    isFavoriteCheck(widget.board).then((value) {
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
            onPressed: () {
              isFavorite
                  ? removeFromFavorites(widget.board)
                  : addFavorites(widget.board);
              isFavorite
                  ? setState(() {
                      isFavorite = false;
                    })
                  : setState(() {
                      isFavorite = true;
                    });
            },
            child: Icon(
              isFavorite ? Icons.star_rate : Icons.star_outline,
              color: CupertinoColors.systemYellow,
            ),
          )
        : IconButton(
            onPressed: () {
              isFavorite
                  ? removeFromFavorites(widget.board)
                  : addFavorites(widget.board);
              isFavorite
                  ? setState(() {
                      isFavorite = false;
                    })
                  : setState(() {
                      isFavorite = true;
                    });
            },
            icon: Icon(
              isFavorite ? Icons.star_rate : Icons.star_outline,
              color: AppColors.kWhite,
            ),
          );
  }
}
