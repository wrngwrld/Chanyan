import 'dart:io';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        foregroundColor: AppColors.kWhite,
        toolbarHeight: 55,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Text(widget.names[index]),
            Text((index + 1).toString() + '/' + widget.list.length.toString()),
          ],
        ),
        actions: [
          if (widget.ext != '.webm' && Platform.isIOS)
            IconButton(
                onPressed: () => {
                      saveVideo(
                        'https://i.4cdn.org/${widget.board}/' +
                            widget.fileNames[index],
                        widget.video,
                        context,
                        true,
                      ),
                    },
                icon: Icon(Icons.download)),
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Share'),
                      value: 0,
                    ),
                  ],
              onSelected: (result) async {
                if (result == 0) {
                  Share.share('https://i.4cdn.org/${widget.board}/' +
                      widget.fileNames[index]);
                }
              })
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
