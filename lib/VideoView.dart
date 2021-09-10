import 'package:flutter/material.dart';
import 'package:flutter_chan/vlcPlayer.dart';

class VideoView extends StatelessWidget {
  VideoView({
    @required this.video,
    @required this.ext,
    @required this.board,
  });

  final String video;
  final String ext;
  final String board;

  @override
  Widget build(BuildContext context) {
    print(ext);
    return Scaffold(
      appBar: AppBar(
        title: Text(video),
      ),
      body: Center(
        child: ext == '.webm'
            ? VLCPlayer(video: video)
            : Image.network('https://i.4cdn.org/$board/$video'),
      ),
    );
  }
}
