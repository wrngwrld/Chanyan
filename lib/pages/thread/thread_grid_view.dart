import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:provider/provider.dart';

class ThreadGridView extends StatefulWidget {
  const ThreadGridView({
    Key key,
    @required this.media,
    @required this.fileNames,
    @required this.board,
    @required this.names,
    @required this.tims,
    @required this.exts,
    @required this.prevTitle,
  }) : super(key: key);

  final List<Widget> media;
  final List<String> fileNames;
  final List<String> names;
  final List<int> tims;
  final List<String> exts;
  final String board;
  final String prevTitle;

  @override
  State<ThreadGridView> createState() => _ThreadGridViewState();
}

class _ThreadGridViewState extends State<ThreadGridView> {
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.black.withOpacity(0.8)
                  : CupertinoColors.white.withOpacity(0.8),
              previousPageTitle: '${widget.prevTitle.substring(0, 9)}...',
              middle: const Text(
                'Media Gallery',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(Icons.download),
                    onPressed: () => {
                      saveAllMedia(
                        'https://i.4cdn.org/${widget.board}/',
                        widget.fileNames,
                        context,
                      ),
                    },
                  ),
                  SizedBox(
                    width: 20,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text('1 Columns'),
                                onPressed: () {
                                  setState(() {
                                    axisCount = 1;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('2 Columns'),
                                onPressed: () {
                                  setState(() {
                                    axisCount = 2;
                                  });

                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('3 Columns'),
                                onPressed: () {
                                  setState(() {
                                    axisCount = 3;
                                  });

                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: const Text(
                'Media Gallery',
              ),
              actions: [
                IconButton(
                  onPressed: () => {
                    saveAllMedia(
                      'https://i.4cdn.org/${widget.board}/',
                      widget.fileNames,
                      context,
                    ),
                  },
                  icon: const Icon(Icons.download),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('1 Columns'),
                      value: 0,
                    ),
                    const PopupMenuItem(
                      child: Text('2 Columns'),
                      value: 1,
                    ),
                    const PopupMenuItem(
                      child: Text('3 Columns'),
                      value: 2,
                    ),
                  ],
                  onSelected: (int result) {
                    switch (result) {
                      case 0:
                        setState(() {
                          axisCount = 1;
                        });

                        break;
                      case 1:
                        setState(() {
                          axisCount = 2;
                        });
                        break;
                      case 2:
                        setState(() {
                          axisCount = 3;
                        });
                        break;
                      default:
                    }
                  },
                )
              ],
            ),
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCount,
        ),
        children: [
          for (int i = 0; i < widget.tims.length; i++)
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MediaPage(
                      video: widget.tims[i].toString() + widget.exts[i],
                      ext: 'webm',
                      board: widget.board,
                      height: 500,
                      width: 500,
                      list: widget.media,
                      names: widget.names,
                      fileNames: widget.fileNames,
                    ),
                  ),
                ),
              },
              child: Image.network(
                'https://i.4cdn.org/${widget.board}/${widget.tims[i]}s.jpg',
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}