import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/favorite_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/Models/board.dart';
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
    final theme = Provider.of<ThemeChanger>(context);
    final favorites = Provider.of<FavoriteProvider>(context);

    isFavorite = favorites.getFavorites().contains(widget.board.board);

    if (isFavorite || !widget.favorites)
      return Slidable(
        actionPane: const SlidableDrawerActionPane(),
        secondaryActions: [
          if (isFavorite)
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => {
                favorites.removeFavorites(widget.board.board),
              },
            )
          else
            IconSlideAction(
              caption: 'Add',
              color: Colors.green,
              icon: Icons.add,
              onTap: () => {
                favorites.addFavorites(widget.board.board),
              },
            ),
        ],
        child: Column(
          children: [
            InkWell(
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
              onLongPress: () => {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    actions: [
                      CupertinoActionSheetAction(
                        child: !isFavorite
                            ? const Text('Add to favorites')
                            : const Text('Remove from favorites'),
                        onPressed: () => {
                          if (isFavorite)
                            favorites.removeFavorites(widget.board.board)
                          else
                            favorites.addFavorites(widget.board.board),
                          Navigator.pop(context),
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () => {
                        Navigator.of(context).pop(),
                      },
                    ),
                  ),
                )
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 5, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '/${widget.board.board}/  -  ${widget.board.title}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Expanded(child: Container()),
                                if (widget.board.wsBoard == 0)
                                  Row(
                                    children: const [
                                      Icon(
                                        CupertinoIcons.exclamationmark_triangle,
                                        size: 12,
                                        color: CupertinoColors.systemRed,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'NSFW',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemRed,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Container()
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              cleanTags(unescape(
                                widget.board.metaDescription,
                              )),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.systemGrey.withOpacity(0.5)
                  : const Color(0x1F000000),
              indent: 5,
              endIndent: 5,
              height: 0,
            ),
          ],
        ),
      );
    else
      return Container();
  }
}
