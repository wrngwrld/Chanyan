import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/favoriteModel.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/board.dart';
import 'package:flutter_chan/pages/boards/board_tile.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class BoardList extends StatefulWidget {
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final favorites = Provider.of<FavoriteProvider>(context);

    return CupertinoPageScaffold(
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
            Platform.isIOS
                ? CupertinoSliverNavigationBar(
                    border: Border.all(color: Colors.transparent),
                    largeTitle: Text(
                      '4chan',
                    ),
                    backgroundColor: theme.getTheme() == ThemeData.dark()
                        ? CupertinoColors.black.withOpacity(0.8)
                        : CupertinoColors.white.withOpacity(0.8),
                  )
                : SliverAppBar(
                    backgroundColor: AppColors.kGreen,
                    foregroundColor: AppColors.kWhite,
                    title: Text(
                      'Chanyan',
                    ),
                    pinned: true,
                  ),
            CupertinoSliverRefreshControl(
              onRefresh: () {
                return Future.delayed(Duration(seconds: 1))
                  ..then((_) {
                    if (mounted) {
                      favorites.loadPreferences();
                    }
                  });
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  FutureBuilder(
                    future: fetchAllBoards(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Board>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Column(
                            children: [
                              SizedBox(
                                height: 100,
                              ),
                              PlatformCircularProgressIndicator(
                                material: (_, __) =>
                                    MaterialProgressIndicatorData(
                                        color: AppColors.kGreen),
                              ),
                            ],
                          );
                          break;
                        default:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 5, 10),
                                child: Text(
                                  'favorites',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              for (Board board in snapshot.data)
                                BoardTile(board: board, favorites: true),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                child: Text(
                                  'all',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: theme.getTheme() == ThemeData.dark()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              for (Board board in snapshot.data)
                                BoardTile(board: board, favorites: false),
                            ],
                          );
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
