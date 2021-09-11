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

  double sliderValue = 0.0;
  bool validPosition = false;
  String position = '';
  String duration = '';

  @override
  void initState() {
    super.initState();

    try {
      _videoPlayerController = VlcPlayerController.network(
        'https://i.4cdn.org/gif/' + widget.video,
        hwAcc: HwAcc.FULL,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    } catch (e) {
      print(e);
    }

    _videoPlayerController.addListener(listener);
  }

  void listener() async {
    if (!mounted) return;
    if (_videoPlayerController.value.isInitialized) {
      var oPosition = _videoPlayerController.value.position;
      var oDuration = _videoPlayerController.value.duration;
      if (oPosition != null && oDuration != null) {
        if (oDuration.inHours == 0) {
          var strPosition = oPosition.toString().split('.')[0];
          var strDuration = oDuration.toString().split('.')[0];
          position =
              "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          duration =
              "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
        } else {
          position = oPosition.toString().split('.')[0];
          duration = oDuration.toString().split('.')[0];
        }
        validPosition = oDuration.compareTo(oPosition) >= 0;
        sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      }
      setState(() {});
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    _videoPlayerController.setTime(sliderValue.toInt() * 1000);
  }

  void _togglePlaying() async {
    setState(() {
      _videoPlayerController.value.isPlaying
          ? _videoPlayerController.pause()
          : _videoPlayerController.play();
      if (_videoPlayerController.value.isEnded) {
        _videoPlayerController.stop();
        _videoPlayerController.play();
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(listener);
    _videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: widget.width / widget.height,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: _videoPlayerController.value.isPlaying
                          ? Icon(Icons.pause_circle_outline)
                          : Icon(Icons.play_circle_outline),
                      onPressed: _togglePlaying,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            position,
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(
                            child: Slider(
                              activeColor: Colors.green,
                              inactiveColor: Colors.white,
                              value: sliderValue,
                              min: 0.0,
                              max: (!validPosition &&
                                      _videoPlayerController.value.duration ==
                                          null)
                                  ? 1.0
                                  : _videoPlayerController
                                      .value.duration.inSeconds
                                      .toDouble(),
                              onChanged: validPosition
                                  ? _onSliderPositionChanged
                                  : null,
                            ),
                          ),
                          Text(
                            duration,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
