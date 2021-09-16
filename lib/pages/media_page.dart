import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:preload_page_view/preload_page_view.dart';
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
  MediaView mediaView = MediaView.pageView;
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
      setState(() {
        // index = controller.page.toInt();
      });
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
        title: mediaView == MediaView.pageView
            ? Column(
                children: [
                  Text(widget.names[index]),
                  Text((index + 1).toString() +
                      '/' +
                      widget.list.length.toString()),
                ],
              )
            : Text(widget.video),
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
                      child: Text("Copy Link"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Scrollable View"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Single View"),
                      value: 2,
                    ),
                  ],
              onSelected: (result) {
                String clipboardText =
                    'https://i.4cdn.org/${widget.board}/${widget.video}';

                if (result == 0) {
                  Clipboard.setData(
                          new ClipboardData(text: clipboardText.toString()))
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Video address copied to clipboard")));
                  });
                }
                if (result == 1) {
                  setState(() {
                    mediaView = MediaView.pageView;
                  });
                }
                if (result == 2) {
                  setState(() {
                    mediaView = MediaView.singleView;
                  });
                }
              })
        ],
      ),
      body: mediaView == MediaView.pageView
          ? PreloadPageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: widget.list,
              physics: ClampingScrollPhysics(),
              onPageChanged: (i) => onPageChanged(i),
              preloadPagesCount: 2,
            )
          : Column(
              children: [
                Expanded(
                  child: widget.ext == '.webm'
                      ? VLCPlayer(
                          board: widget.board,
                          video: widget.video,
                          height: widget.height,
                          width: widget.width,
                          fileName: widget.fileNames[index],
                        )
                      : InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 5,
                          child: Image.network(
                            'https://i.4cdn.org/${widget.board}/${widget.video}',
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
