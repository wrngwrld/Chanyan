import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/vlcPlayer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoView extends StatelessWidget {
  VideoView({
    @required this.video,
    @required this.ext,
    @required this.board,
    @required this.height,
    @required this.width,
  });

  final String video;
  final String ext;
  final String board;
  final int height;
  final int width;

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
          print(directory);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(video),
        actions: [
          IconButton(
              onPressed: () => {
                    // downloadFile(),
                    saveVideo('https://i.4cdn.org/$board/$video', video),
                  },
              icon: Icon(Icons.download)),
        ],
      ),
      body: Center(
        child: ext == '.webm'
            ? VLCPlayer(
                video: video,
                height: height,
                width: width,
              )
            : Image.network(
                'https://i.4cdn.org/$board/$video',
              ),
      ),
    );
  }
}
