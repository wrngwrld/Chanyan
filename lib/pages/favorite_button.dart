import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/favorite_model.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({Key? key, required this.board}) : super(key: key);

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

    return CupertinoButton(
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
    );
  }
}
