import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaListPage extends StatefulWidget {
  MediaListPage({
    @required this.video,
    @required this.ext,
    @required this.board,
    @required this.height,
    @required this.width,
    @required this.list,
    @required this.startVideo,
    @required this.names,
  });

  final String video;
  final String ext;
  final String board;
  final int height;
  final int width;
  final int startVideo;

  final List<Widget> list;
  final List<String> names;

  @override
  _MediaListPageState createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  PageController controller;

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

  Future<bool> saveVideo(String url, String fileName) async {
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
          newPath = newPath + "/RPSApp";
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
              isReturnPathOfIOS: true);
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  int index;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.startVideo);

    controller.addListener(() {
      setState(() {
        index = controller.page.toInt();
      });
    });
  }

  final String page = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 55,
        backgroundColor: Colors.black,
        title: Column(
          children: [
            Text(index == null
                ? widget.names[widget.startVideo].toString()
                : widget.names[index].toString()),
            Text(
              index == null
                  ? widget.startVideo.toString() +
                      '/' +
                      (widget.list.length - 1).toString()
                  : index.toString() +
                      '/' +
                      (widget.list.length - 1).toString(),
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
        actions: [
          widget.ext != '.webm'
              ? IconButton(
                  onPressed: () => {
                        // downloadFile(),
                        saveVideo(
                            'https://i.4cdn.org/${widget.board}/${widget.video}',
                            widget.video),
                      },
                  icon: Icon(Icons.download))
              : Container(),
        ],
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        children: widget.list,
        dragStartBehavior: DragStartBehavior.down,
      ),
    );
  }
}
