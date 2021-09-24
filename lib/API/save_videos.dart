import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    final result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}

Future<bool> saveVideo(String url, String fileName, BuildContext context,
    bool showSnackBar) async {
  Directory directory;
  final dio = Dio();

  try {
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        directory = await getExternalStorageDirectory();
        String newPath = '';
        final List<String> paths = directory.path.split('/');
        for (int x = 1; x < paths.length; x++) {
          final String folder = paths[x];
          if (folder != 'Android') {
            newPath += '/$folder';
          } else {
            break;
          }
        }
        newPath = '$newPath/Download/4Chan';
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
      final File saveFile = File('${directory.path}/$fileName');
      await dio.download(url, saveFile.path,
          onReceiveProgress: (value1, value2) {});
      if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(saveFile.path, isReturnPathOfIOS: true)
            .then((value) => {
                  if (showSnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File downloaded!'),
                      ),
                    ),
                });
      }
      return true;
    }
  } catch (e) {
    print(e);
  }
  return false;
}

Future<void> saveAllMedia(
    String url, List<String> fileNames, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Downloading...'),
    ),
  );
  for (final String fileName in fileNames) {
    await saveVideo(url + fileName, fileName, context, false);
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('All files downloaded!'),
    ),
  );
}
