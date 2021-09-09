import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaVideoPlayer extends StatefulWidget {
  MediaVideoPlayer({
    @required this.video,
  });

  final String video;

  @override
  _MediaVideoPlayerState createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  VideoPlayerController videoPlayerController;

  ChewieController chewieController;

  Future<ChewieController> getVideo() async {
    videoPlayerController =
        VideoPlayerController.network('https://i.4cdn.org/gif/' + widget.video);

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: false,
      allowPlaybackSpeedChanging: false,
    );

    return chewieController;
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getVideo(),
      builder: (
        BuildContext context,
        AsyncSnapshot<ChewieController> snapshot,
      ) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            );
            break;
          default:
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Chewie(
                    controller: snapshot.data,
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
