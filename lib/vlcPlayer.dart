import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VLCPlayer extends StatefulWidget {
  VLCPlayer({
    @required this.video,
  });

  final String video;

  @override
  _VLCPlayerState createState() => _VLCPlayerState();
}

class _VLCPlayerState extends State<VLCPlayer> {
  VlcPlayerController _videoPlayerController;

  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.network(
      'https://i.4cdn.org/gif/' + widget.video,
      // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      hwAcc: HwAcc.FULL,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VlcPlayer(
      controller: _videoPlayerController,
      aspectRatio: 16 / 9,
      placeholder: Center(child: CircularProgressIndicator()),
    );
  }
}
