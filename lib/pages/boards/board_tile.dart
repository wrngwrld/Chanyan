import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/favorites.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/board/board_page.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:flutter_chan/services/string.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BoardTile extends StatefulWidget {
  const BoardTile({
    @required this.board,
    @required this.favorites,
  });

  final Board board;
  final bool favorites;

  @override
  State<BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    isFavoriteCheck(widget.board.board).then((value) {
      setState(() {
        isFavorite = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    if (isFavorite || !widget.favorites)
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          isFavorite
              ? IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => {
                    removeFromFavorites(widget.board.board),
                    setState(() {
                      isFavorite = false;
                    })
                  },
                )
              : IconSlideAction(
                  caption: 'Add',
                  color: Colors.green,
                  icon: Icons.add,
                  onTap: () => {
                    addFavorites(widget.board.board),
                    setState(() {
                      isFavorite = true;
                    })
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
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '/' +
                                widget.board.board +
                                '/  -  ' +
                                widget.board.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: Platform.isIOS
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: theme.getTheme() == ThemeData.dark()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            Stringz.cleanTags(Stringz.unescape(
                              widget.board.metaDescription,
                            )),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.systemGrey.withOpacity(0.5)
                  : Color(0x1F000000),
              indent: 5,
              endIndent: 5,
            ),
          ],
        ),
      );
    else
      return Container();
  }
}
