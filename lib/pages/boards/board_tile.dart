import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/board.dart';
import 'package:flutter_chan/blocs/favorite_model.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BoardTile extends StatefulWidget {
  const BoardTile({
    Key key,
    @required this.board,
    @required this.favorites,
  }) : super(key: key);

  final Board board;
  final bool favorites;

  @override
  State<BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteProvider>(context);

    isFavorite = favorites.getFavorites().contains(widget.board.board);

    return Slidable(
      endActionPane: isFavorite
          ? ActionPane(
              extentRatio: 0.3,
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  label: 'Remove',
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  onPressed: (context) => {
                    favorites.removeFavorites(widget.board.board),
                  },
                )
              ],
            )
          : ActionPane(
              extentRatio: 0.3,
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  label: 'Add',
                  backgroundColor: Colors.green,
                  icon: Icons.add,
                  onPressed: (context) => {
                    favorites.addFavorites(widget.board.board),
                  },
                )
              ],
            ),
      child: CupertinoListTile.notched(
        title: Row(
          children: [
            Text(widget.board.title),
            if (widget.board.wsBoard == 0)
              Row(
                children: const [
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'NSFW',
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 10,
                    ),
                  ),
                ],
              )
          ],
        ),
        subtitle: SizedBox(
          width: MediaQuery.of(context).size.height * 0.3,
          child: Text(
            cleanTags(unescape(
              widget.board.metaDescription,
            )),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        additionalInfo: RichText(
          text: TextSpan(
            text: widget.board.board.length > 3
                ? widget.board.board.substring(0, 3)
                : widget.board.board,
            style: const TextStyle(
              color: CupertinoColors.inactiveGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: const CupertinoListTileChevron(),
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BoardPage(
                boardName: widget.board.title,
                board: widget.board.board,
              ),
            ),
          )
        },
      ),
    );
  }
}
