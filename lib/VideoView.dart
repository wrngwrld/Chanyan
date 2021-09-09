import 'package:flutter/material.dart';
import 'package:flutter_chan/VideoPlayer.dart';

class VideoView extends StatelessWidget {
  VideoView({
    @required this.video,
  });

  final String video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video),
      ),
      body: MediaVideoPlayer(video: video),
    );
  }
}
