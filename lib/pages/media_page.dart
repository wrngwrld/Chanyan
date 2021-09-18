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
  MediaPage({
    @required this.video,
    @required this.ext,
    @required this.board,
    @required this.height,
    @required this.width,
    @required this.list,
    @required this.names,
    @required this.fileNames,
  });

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

  final String page = '0';
  int index;
  String currentName = "";

  onPageChanged(int i) {
    index = i;
  }

  setStartVideo(String video) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: Platform.isIOS
          ? CupertinoNavigationBar(
              backgroundColor: Colors.black,
              middle: Column(
                children: [
                  Text(
                    widget.names[index],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    (index + 1).toString() +
                        '/' +
                        widget.list.length.toString(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                child: Text('Open in Browser'),
                                onPressed: () {
                                  launchURL(
                                    'https://i.4cdn.org/${widget.board}/' +
                                        widget.fileNames[index],
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Share'),
                                onPressed: () {
                                  Share.share(
                                    'https://i.4cdn.org/${widget.board}/' +
                                        widget.fileNames[index],
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Download'),
                                onPressed: () {
                                  saveVideo(
                                    'https://i.4cdn.org/${widget.board}/' +
                                        widget.fileNames[index],
                                    widget.fileNames[index],
                                    context,
                                    true,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.ios_share),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: AppColors.kWhite,
              title: Column(
                children: [
                  Text(widget.names[index]),
                  Text((index + 1).toString() +
                      '/' +
                      widget.list.length.toString()),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () => {
                          Share.share('https://i.4cdn.org/${widget.board}/' +
                              widget.fileNames[index])
                        },
                    icon: Icon(Icons.share)),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Open in Browser"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Share"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Download"),
                      value: 2,
                    ),
                  ],
                  onSelected: (result) {
                    switch (result) {
                      case 0:
                        launchURL(
                          'https://i.4cdn.org/${widget.board}/' +
                              widget.fileNames[index],
                        );
                        break;
                      case 1:
                        Share.share(
                          'https://i.4cdn.org/${widget.board}/' +
                              widget.fileNames[index],
                        );
                        break;
                      case 2:
                        saveVideo(
                          'https://i.4cdn.org/${widget.board}/' +
                              widget.fileNames[index],
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
        physics: ClampingScrollPhysics(),
        onPageChanged: (i) => onPageChanged(i),
        preloadPagesCount: 2,
      ),
    );
  }
}
