import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/widgets/video_controls.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    Key? key,
    required this.video,
    this.board,
    this.isAsset = false,
    required this.fileName,
    this.directory,
    this.ext = 'mp4',
  }) : super(key: key);

  final String video;
  final String? board;
  final bool isAsset;
  final String fileName;
  final Directory? directory;
  final String? ext;

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  late final player = Player();

  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    if (widget.isAsset) {
      player.open(Media(
          '${widget.directory!.path}/savedAttachments/${getNameWithoutExtension(widget.fileName)}${widget.ext}'));
    } else {
      player.open(Media('https://i.4cdn.org/${widget.board}/${widget.video}'));
    }

    player.setPlaylistMode(PlaylistMode.loop);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: SafeArea(
          child: Video(
            controller: controller,
            controls: NoVideoControls,
            fill: Colors.transparent,
          ),
        ),
      ),
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VideoControls(
                controller: controller,
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
