import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/saved_attachment.dart';
import 'package:flutter_chan/blocs/saved_attachments_model.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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

Future<Directory> requestDirectory(Directory directory) async {
  if (Platform.isAndroid) {
    if (await _requestPermission(Permission.storage)) {
      directory = (await getExternalStorageDirectory())!;
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
      directory = await getApplicationDocumentsDirectory();
    }
  }

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  return directory;
}

Future<ReturnCode?> convertWebMToMP4(File webmFile, File mp4File) async {
  mp4File = File(mp4File.path.replaceAll('.webm', '.mp4'));

  final FFmpegSession session = await FFmpegKit.execute(
    '-y -i ${webmFile.path} -c:v mpeg4 -qscale 0 ${mp4File.path}',
  );

  return session.getReturnCode();
}

Future<void> saveVideo(
  String url,
  String fileName,
  BuildContext context, {
  bool showSnackBar = false,
  bool isSaved = true,
}) async {
  final SavedAttachmentsProvider savedAttachmentsProvider =
      Provider.of<SavedAttachmentsProvider>(context, listen: false);

  savedAttachmentsProvider.pauseVideo();

  Directory directory = Directory('');
  final dio = Dio();

  if (isSaved) {
    directory = await requestDirectory(directory);

    if (Platform.isIOS) {
      await ImageGallerySaver.saveFile(
        '${directory.path}/savedAttachments/$fileName'
            .replaceAll('.webm', '.mp4'),
        isReturnPathOfIOS: true,
      ).then((value) => {
            if (showSnackBar)
              showCupertinoSnackbar(
                const Duration(milliseconds: 1800),
                true,
                context,
                'File saved!',
              )
            else
              null,
          });
    } else {
      await ImageGallerySaver.saveFile(
        '${directory.path}/savedAttachments/$fileName'
            .replaceAll('.webm', '.mp4'),
        isReturnPathOfIOS: true,
      ).then((value) => {
            if (showSnackBar)
              showCupertinoSnackbar(
                const Duration(milliseconds: 1800),
                true,
                context,
                'File saved!',
              )
            else
              null,
          });
    }
  } else {
    Navigator.pop(context);

    showCupertinoSnackbar(
      null,
      false,
      context,
      'Downloading...',
    );

    showCupertinoSnackbar(
      null,
      false,
      context,
      'Downloading...',
    );

    final String ext = '.${fileName.split('.').last}';

    try {
      directory = await requestDirectory(directory);

      if (await directory.exists()) {
        final File saveFile = File('${directory.path}/$fileName');
        final File saveFileVideo = File('${directory.path}/$fileName');

        await dio.download(
          url,
          saveFile.path,
        );

        if (Platform.isIOS) {
          if (ext == '.webm') {
            Navigator.pop(context);
            showCupertinoSnackbar(
              null,
              false,
              context,
              'File converting...',
            );

            final ReturnCode? returnCode =
                (await convertWebMToMP4(saveFile, saveFileVideo))
                    as ReturnCode?;

            if (ReturnCode.isSuccess(returnCode)) {
              await ImageGallerySaver.saveFile(
                saveFileVideo.path.replaceAll('.webm', '.mp4'),
                isReturnPathOfIOS: true,
              ).then((value) => {
                    if (showSnackBar) Navigator.pop(context),
                    if (showSnackBar)
                      showCupertinoSnackbar(
                        const Duration(milliseconds: 1800),
                        true,
                        context,
                        'File downloaded!',
                      )
                    else
                      null,
                  });
            } else {
              Navigator.pop(context);
              showCupertinoSnackbar(
                const Duration(milliseconds: 1800),
                true,
                context,
                'Download failed :(',
              );
            }
          } else {
            await ImageGallerySaver.saveFile(saveFile.path,
                    isReturnPathOfIOS: true)
                .then((value) => {
                      if (showSnackBar) Navigator.pop(context),
                      if (showSnackBar)
                        showCupertinoSnackbar(
                          const Duration(milliseconds: 1800),
                          true,
                          context,
                          'File downloaded!',
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

  savedAttachmentsProvider.startVideo();
}

Future<void> saveAllMedia(
    String url, List<String> fileNames, BuildContext context) async {
  showCupertinoSnackbar(
    null,
    false,
    context,
    'Downloading...',
  );

  for (final String fileName in fileNames) {
    await saveVideo(
      url + fileName,
      fileName,
      context,
    );
  }

  Navigator.of(context).pop(true);

  showCupertinoSnackbar(
    const Duration(milliseconds: 1800),
    true,
    context,
    'All files downloaded!',
  );
}

Future<void> shareMedia(
  String url,
  String fileName,
  BuildContext context, {
  bool isSaved = false,
}) async {
  Directory directory = Directory('');
  final dio = Dio();

  final SavedAttachmentsProvider savedAttachmentsProvider =
      Provider.of<SavedAttachmentsProvider>(context, listen: false);

  savedAttachmentsProvider.pauseVideo();

  if (isSaved) {
    directory = await requestDirectory(directory);

    Share.shareFiles([
      '${directory.path}/savedAttachments/$fileName'
          .replaceAll('.webm', '.mp4'),
    ]);
  } else {
    Navigator.pop(context);

    showCupertinoSnackbar(
      null,
      false,
      context,
      'Downloading...',
    );
    showCupertinoSnackbar(
      null,
      false,
      context,
      'Downloading...',
    );

    try {
      directory = await requestDirectory(directory);

      if (await directory.exists()) {
        final File saveFile = File('${directory.path}/$fileName');
        final File saveFileVideo = File('${directory.path}/$fileName');

        await dio.download(
          url,
          saveFile.path,
        );

        final String ext = '.${fileName.split('.').last}';

        if (Platform.isIOS) {
          if (ext == '.webm') {
            Navigator.pop(context);
            showCupertinoSnackbar(
              null,
              false,
              context,
              'File converting...',
            );

            final ReturnCode? returnCode =
                (await convertWebMToMP4(saveFile, saveFileVideo))
                    as ReturnCode?;

            if (ReturnCode.isSuccess(returnCode)) {
              Navigator.pop(context);
              showCupertinoSnackbar(
                const Duration(milliseconds: 1000),
                true,
                context,
                'File downloaded!',
              ).then((value) => {
                    Share.shareFiles([
                      saveFileVideo.path.replaceAll('.webm', '.mp4'),
                    ]),
                  });
            } else {
              Navigator.pop(context);
              showCupertinoSnackbar(
                const Duration(milliseconds: 1800),
                true,
                context,
                'Download failed :(',
              );
            }
          } else {
            Navigator.pop(context);
            showCupertinoSnackbar(
              const Duration(milliseconds: 1000),
              true,
              context,
              'File downloaded!',
            ).then((value) => {
                  Share.shareFiles([saveFile.path])
                });
          }
        } else {
          Navigator.pop(context);
          Share.shareFiles([saveFile.path]);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  savedAttachmentsProvider.startVideo();
}

Future<SavedAttachment?> saveAttachment(
  String url,
  String thumbnailUrl,
  String fileName,
  BuildContext context,
  SavedAttachmentsProvider savedAttachmentsProvider,
) async {
  Directory directory = Directory('');
  final dio = Dio();

  final SavedAttachmentsProvider savedAttachmentsProvider =
      Provider.of<SavedAttachmentsProvider>(context, listen: false);

  savedAttachmentsProvider.pauseVideo();

  showCupertinoSnackbar(
    null,
    false,
    context,
    'Downloading...',
  );

  try {
    directory = await requestDirectory(directory);

    if (await directory.exists()) {
      final File saveFile = File('${directory.path}/$fileName');
      File saveFileVideo;

      final Directory savedAttachmentsDirectory =
          Directory('${directory.path}/savedAttachments');

      if (!await savedAttachmentsDirectory.exists()) {
        await savedAttachmentsDirectory.create(recursive: true);
      }

      saveFileVideo = File('${directory.path}/savedAttachments/$fileName');

      await dio.download(
        url,
        saveFile.path,
      );

      final String ext = '.${fileName.split('.').last}';

      if (Platform.isIOS) {
        Navigator.pop(context);
        if (ext == '.webm') {
          showCupertinoSnackbar(
            null,
            false,
            context,
            'File converting...',
          );

          final ReturnCode? returnCode =
              (await convertWebMToMP4(saveFile, saveFileVideo)) as ReturnCode?;

          if (ReturnCode.isSuccess(returnCode)) {
            final String thumbnailPath = await downloadThumbnail(
              fileName,
              thumbnailUrl,
              '${directory.path}/savedAttachments/',
              dio,
            );

            Navigator.pop(context);

            showCupertinoSnackbar(
              const Duration(milliseconds: 1800),
              true,
              context,
              'File downloaded!',
            );

            savedAttachmentsProvider.startVideo();

            return SavedAttachment(
              savedAttachmentType: 'Video',
              fileName: fileName,
              thumbnail: thumbnailPath,
            );
          } else {
            savedAttachmentsProvider.startVideo();

            showCupertinoSnackbar(
              const Duration(milliseconds: 1800),
              true,
              context,
              'Download failed :(',
            );

            return null;
          }
        } else {
          saveFile.copy(saveFileVideo.path);

          if (ext == '.mp4') {
            final String thumbnailPath = await downloadThumbnail(
              fileName,
              thumbnailUrl,
              '${directory.path}/savedAttachments/',
              dio,
            );

            Navigator.pop(context);

            showCupertinoSnackbar(
              const Duration(milliseconds: 1800),
              true,
              context,
              'File downloaded!',
            );

            savedAttachmentsProvider.startVideo();

            return SavedAttachment(
              savedAttachmentType: 'Video',
              fileName: fileName,
              thumbnail: thumbnailPath,
            );
          } else {
            showCupertinoSnackbar(
              const Duration(milliseconds: 1800),
              true,
              context,
              'File downloaded!',
            );

            savedAttachmentsProvider.startVideo();

            return SavedAttachment(
              savedAttachmentType: ext == '.mp4' ? 'Video' : 'Image',
              fileName: fileName,
              thumbnail: fileName,
            );
          }
        }
      } else {
        saveFile.copy(saveFileVideo.path);

        Navigator.pop(context);

        showCupertinoSnackbar(
          const Duration(milliseconds: 1800),
          true,
          context,
          'File downloaded!',
        );

        savedAttachmentsProvider.startVideo();

        return SavedAttachment(
          savedAttachmentType: 'Image',
          fileName: fileName,
          thumbnail: fileName,
        );
      }
    }

    savedAttachmentsProvider.startVideo();

    return null;
  } catch (e) {
    print(e);

    savedAttachmentsProvider.startVideo();

    return null;
  }
}

Future<dynamic> showCupertinoSnackbar(
  Duration? duration,
  bool dismissable,
  BuildContext context,
  String message,
) {
  return showCupertinoDialog(
    context: context,
    builder: (context) {
      if (duration != null) {
        Future.delayed(duration, () {
          Navigator.of(context).pop(true);
        });
      }
      return GestureDetector(
        onTap: () {
          if (dismissable) {
            Navigator.of(context).pop(true);
          }
        },
        child: CupertinoAlertDialog(
          title: Text(message),
        ),
      );
    },
  );
}

Future<String> downloadThumbnail(
  String fileName,
  String thumbnailUrl,
  String path,
  Dio dio,
) async {
  final String nameWithoutExtension = getNameWithoutExtension(fileName);

  await dio.download(
    thumbnailUrl,
    '$path$nameWithoutExtension.jpg',
  );

  return '$nameWithoutExtension.jpg';
}

String getNameWithoutExtension(String fileName) {
  if (fileName.contains('.')) {
    return fileName.substring(0, fileName.lastIndexOf('.'));
  } else {
    return fileName;
  }
}
