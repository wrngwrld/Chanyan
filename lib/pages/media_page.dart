import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/constants.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({
    Key key,
    @required this.video,
    @required this.ext,
    @required this.board,
    @required this.height,
    @required this.width,
    @required this.list,
    @required this.names,
    @required this.fileNames,
  }) : super(key: key);

  final String video;
  final String ext;
  final String board;
  final int height;
  final int width;

  final List<Widget> list;
  final List<String> names;
  final List<String> fileNames;

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  PreloadPageController controller;

  bool isDark = true;

  final String page = '0';
  int index;
  String currentName = '';

  void onPageChanged(int i) {
    setState(() {
      index = i;
    });
  }

  Future<void> setStartVideo(String video) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('startVideo', video);
  }

  @override
  void initState() {
    super.initState();

    index = widget.fileNames.indexWhere((element) => element == widget.video);

    setStartVideo(widget.names[index]);

    controller = PreloadPageController(
      initialPage: index,
      keepPage: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: isDark ? Colors.black : Colors.white,
              middle: Column(
                children: [
                  Text(
                    widget.names[index],
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${index + 1}/${widget.list.length}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => {
                      setState(() {
                        isDark = !isDark;
                      })
                    },
                    child: const Icon(
                      Icons.wb_sunny,
                      color: CupertinoColors.activeBlue,
                    ),
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
                                child: const Text('Open in Browser'),
                                onPressed: () {
                                  launchURL(
                                    'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Share'),
                                onPressed: () {
                                  Share.share(
                                    'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Download'),
                                onPressed: () {
                                  saveVideo(
                                    'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                                    widget.fileNames[index],
                                    context,
                                    true,
                                  );
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
                      child: const Icon(Icons.ios_share),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: isDark ? Colors.black : Colors.white,
              foregroundColor: isDark ? Colors.white : AppColors.kBlack,
              title: Column(
                children: [
                  Text(widget.names[index]),
                  Text('${index + 1}/${widget.list.length}'),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () => {
                          setState(() {
                            isDark = !isDark;
                          })
                        },
                    icon: const Icon(Icons.wb_sunny)),
                PopupMenuButton(
                  icon: const Icon(Icons.share),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Open in Browser'),
                      value: 0,
                    ),
                    const PopupMenuItem(
                      child: Text('Share'),
                      value: 1,
                    ),
                    const PopupMenuItem(
                      child: Text('Download'),
                      value: 2,
                    ),
                  ],
                  onSelected: (int result) {
                    switch (result) {
                      case 0:
                        launchURL(
                          'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                        );
                        break;
                      case 1:
                        Share.share(
                          'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                        );
                        break;
                      case 2:
                        saveVideo(
                          'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                          widget.fileNames[index],
                          context,
                          true,
                        );
                        break;
                      default:
                    }
                  },
                )
              ],
            ),
      body: PreloadPageView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        children: widget.list,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (i) => onPageChanged(i),
        preloadPagesCount: 2,
      ),
    );
  }
}
