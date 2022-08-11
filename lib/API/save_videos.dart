import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

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

Future<void> saveVideo(String url, String fileName, BuildContext context,
    {bool showSnackBar = false, bool share = false}) async {
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
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        directory = await getTemporaryDirectory();
      }
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    if (await directory.exists()) {
      final File saveFile = File('${directory.path}/$fileName');
      final File saveFileVideo = File('${directory.path}/$fileName');

      await dio.download(
        url,
        saveFile.path,
        // onReceiveProgress: (value1, value2) {
        //   print(value1);
        // },
      );

      final String ext = '.${fileName.split('.').last}';

      if (Platform.isIOS) {
        if (ext == '.webm') {
          FFmpegKit.execute(
            '-y -i ${saveFile.path} -c:v mpeg4 -qscale 0 ${saveFileVideo.path}.mp4',
          ).then((session) async {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              if (share)
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      Navigator.of(context).pop(true);
                    });
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const CupertinoAlertDialog(
                        title: Text('File downloaded!'),
                      ),
                    );
                  },
                ).then((value) => {
                      Share.shareFiles(['${saveFileVideo.path}.mp4']),
                    });
              else
                await ImageGallerySaver.saveFile(
                  '${saveFileVideo.path}.mp4',
                  isReturnPathOfIOS: true,
                ).then((value) => {
                      if (showSnackBar)
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(const Duration(milliseconds: 1800),
                                () {
                              Navigator.of(context).pop(true);
                            });
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const CupertinoAlertDialog(
                                title: Text('File downloaded!'),
                              ),
                            );
                          },
                        )
                      else
                        null,
                    });
            } else {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(milliseconds: 1800), () {
                    Navigator.of(context).pop(true);
                  });
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const CupertinoAlertDialog(
                      title: Text('Download failed :('),
                    ),
                  );
                },
              );
            }
          });
        } else {
          if (share)
            showCupertinoDialog(
              context: context,
              builder: (context) {
                Future.delayed(const Duration(milliseconds: 1000), () {
                  Navigator.of(context).pop(true);
                });
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const CupertinoAlertDialog(
                    title: Text('File downloaded!'),
                  ),
                );
              },
            ).then((value) => {
                  Share.shareFiles([saveFile.path])
                });
          else
            await ImageGallerySaver.saveFile(saveFile.path,
                    isReturnPathOfIOS: true)
                .then((value) => {
                      if (showSnackBar)
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(const Duration(milliseconds: 1800),
                                () {
                              Navigator.of(context).pop(true);
                            });
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const CupertinoAlertDialog(
                                title: Text('File downloaded!'),
                              ),
                            );
                          },
                        )
                      else
                        null,
                    });
        }
      }
    }
  } catch (e) {
    print(e);
  }
}

Future<void> saveAllMedia(
    String url, List<String> fileNames, BuildContext context) async {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return const CupertinoAlertDialog(
        title: Text('Downloading...'),
      );
    },
  );
  for (final String fileName in fileNames) {
    await saveVideo(
      url + fileName,
      fileName,
      context,
    );
  }
  Navigator.of(context).pop(true);
  showCupertinoDialog(
    context: context,
    builder: (context) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        Navigator.of(context).pop(true);
      });
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop(true);
        },
        child: const CupertinoAlertDialog(
          title: Text('All files downloaded!'),
        ),
      );
    },
  );
}
