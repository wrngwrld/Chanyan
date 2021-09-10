import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VLCPlayer extends StatefulWidget {
  VLCPlayer({
    @required this.video,
    @required this.height,
    @required this.width,
  });

  final String video;
  final int height;
  final int width;

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
      hwAcc: HwAcc.FULL,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VlcPlayer(
      controller: _videoPlayerController,
      aspectRatio: widget.width / widget.height,
      placeholder: Center(child: CircularProgressIndicator()),
    );
  }
}
