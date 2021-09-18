import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VLCPlayer extends StatefulWidget {
  VLCPlayer({
    @required this.video,
    @required this.board,
    @required this.height,
    @required this.width,
    @required this.fileName,
  });

  final String video;
  final String board;
  final int height;
  final int width;
  final String fileName;

  @override
  _VLCPlayerState createState() => _VLCPlayerState();
}

class _VLCPlayerState extends State<VLCPlayer> {
  VlcPlayerController _videoPlayerController;

  bool isVisible = false;

  Future<void> initializePlayer() async {}

  double sliderValue = 0.0;
  bool validPosition = false;
  String position = '';
  String duration = '';

  bool controllsVisible = true;

  @override
  void initState() {
    super.initState();

    fetchStartVideo();

    try {
      _videoPlayerController = VlcPlayerController.network(
        'https://i.4cdn.org/${widget.board}/' + widget.video,
        hwAcc: HwAcc.FULL,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
          ]),
        ),
      );
    } catch (e) {
      print(e);
    }

    _videoPlayerController.addListener(listener);
  }

  fetchStartVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String startVideo = prefs.getString('startVideo');

    if (startVideo == widget.fileName + '.webm')
      setState(() {
        isVisible = true;
      });
  }

  void listener() async {
    if (!mounted) return;

    if (!isVisible) {
      _videoPlayerController.pause();
    }

    if (_videoPlayerController.value.isInitialized && isVisible) {
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

    if (_videoPlayerController.value.isEnded) {
      _videoPlayerController.stop();
      _videoPlayerController.play();
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    _videoPlayerController.setTime(sliderValue.toInt() * 1000);
  }

  void _togglePlaying() async {
    setState(() {
      _videoPlayerController.value.isPlaying
          ? _videoPlayerController.pause()
          : _videoPlayerController.play();

      isVisible ? isVisible = false : isVisible = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: PlatformCircularProgressIndicator(
            material: (_, __) =>
                MaterialProgressIndicatorData(color: AppColors.kGreen),
          ),
        ),
        VisibilityDetector(
          key: ObjectKey(widget.video),
          onVisibilityChanged: (visibility) {
            if (visibility.visibleFraction < 0.5 &&
                this.mounted &&
                _videoPlayerController.value.isInitialized) {
              _videoPlayerController.pause();

              setState(() {
                isVisible = false;
              });
            }
            if (visibility.visibleFraction > 0.5 &&
                this.mounted &&
                _videoPlayerController.value.isInitialized) {
              _videoPlayerController.play();

              setState(() {
                isVisible = true;
              });
            }
          },
          child: GestureDetector(
            onTap: () => {
              setState(() {
                controllsVisible = !controllsVisible;
              })
            },
            child: Container(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VlcPlayer(
                        controller: _videoPlayerController,
                        aspectRatio: widget.width / widget.height,
                        placeholder: Center(
                          child: PlatformCircularProgressIndicator(
                            material: (_, __) => MaterialProgressIndicatorData(
                              color: AppColors.kGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: controllsVisible ? 1 : 0,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            height: 45,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(50, 50, 50, 0.85),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  color: Colors.white,
                                  icon: _videoPlayerController.value.isPlaying
                                      ? Icon(Icons.pause)
                                      : Icon(Icons.play_arrow),
                                  onPressed: _togglePlaying,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        position,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Platform.isIOS
                                              ? CupertinoColors.systemGrey
                                              : AppColors.kGreen,
                                          inactiveColor: Platform.isIOS
                                              ? CupertinoColors.systemFill
                                              : AppColors.kWhite,
                                          thumbColor: Platform.isIOS
                                              ? CupertinoColors.white
                                              : AppColors.kWhite,
                                          value: sliderValue,
                                          min: 0.0,
                                          max: (!validPosition &&
                                                  _videoPlayerController
                                                          .value.duration ==
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
