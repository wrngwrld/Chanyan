import 'package:flutter_chan/widgets/image_viewer.dart';
import 'package:media_kit/media_kit.dart';

class MediaMetadata {
  MediaMetadata({
    required this.videoId,
    required this.videoName,
    required this.fileName,
    required this.ext,
  });

  int videoId;
  String videoName;
  String fileName;
  String ext;
}

class MediaPageItem {
  MediaPageItem({
    this.isVideo = false,
    this.player,
    this.viewer,
  });

  bool isVideo;
  Player? player;
  ImageViewer? viewer;
}
