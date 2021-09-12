import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/board/grid_view.dart';
import 'package:flutter_chan/pages/board/list_view.dart';
import 'package:flutter_chan/widgets/floating_action_buttons.dart';

class BoardPage extends StatefulWidget {
  BoardPage({
    @required this.board,
    @required this.name,
  });

  final board;
  final name;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ScrollController scrollController = ScrollController();

  Sort sortBy = Sort.byImagesCount;
  View view = View.gridView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kGreen,
        foregroundColor: AppColors.kWhite,
        title: Text('/' + widget.name + '/'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.sort),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Sort by image count"),
                value: 0,
              ),
              PopupMenuItem(
                child: Text("Sort by reply count"),
                value: 1,
              ),
              PopupMenuItem(
                child: Text("Sort by bump order"),
                value: 2,
              ),
              PopupMenuItem(
                child: Text("Sort by newest"),
                value: 3,
              ),
              PopupMenuItem(
                child: Text("Sort by oldest"),
                value: 4,
              ),
            ],
            onSelected: (result) {
              switch (result) {
                case 0:
                  setState(() {
                    sortBy = Sort.byImagesCount;
                  });
                  break;
                case 1:
                  setState(() {
                    sortBy = Sort.byReplyCount;
                  });

                  break;
                case 2:
                  setState(() {
                    sortBy = Sort.byBumpOrder;
                  });

                  break;
                case 3:
                  setState(() {
                    sortBy = Sort.byNewest;
                  });

                  break;
                case 4:
                  setState(() {
                    sortBy = Sort.byOldest;
                  });

                  break;
                default:
              }
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Grid view"),
                value: 0,
              ),
              PopupMenuItem(
                child: Text("List view"),
                value: 1,
              ),
            ],
            onSelected: (result) {
              switch (result) {
                case 0:
                  setState(() {
                    view = View.gridView;
                  });
                  break;
                case 1:
                  setState(() {
                    view = View.listView;
                  });

                  break;
                default:
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButtons(
        scrollController: scrollController,
      ),
      body: FutureBuilder(
        future: fetchOPs(sortBy, widget.board),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: AppColors.kWhite,
                backgroundColor: AppColors.kGreen,
              );
              break;
            default:
              switch (view) {
                case View.listView:
                  return BoardListView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
                  break;
                case View.gridView:
                  return BoardGridView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
                  break;
                default:
                  return BoardListView(
                    scrollController: scrollController,
                    board: widget.board,
                    snapshot: snapshot,
                  );
              }
          }
        },
      ),
    );
  }
}
