import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  PageController pageController;

  final String page = '0';
  int index;
  String currentName = "";

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> saveVideo(
      String url, String fileName, BuildContext context) async {
    Directory directory;
    var dio = Dio();

    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Download/4Chan";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {});
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
                  isReturnPathOfIOS: true)
              .then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('File downloaded!'),
                  )));
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

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

    pageController = PageController(
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
                          context),
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
          // ? PageView(
          //     scrollDirection: Axis.horizontal,
          //     controller: pageController,
          //     children: widget.list,
          //     physics: ClampingScrollPhysics(),
          //     onPageChanged: (i) => onPageChanged(i),
          //   )
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
