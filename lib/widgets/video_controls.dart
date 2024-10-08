import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mutex/mutex.dart';

const _positionUpdatePeriod = Duration(milliseconds: 30);

class VideoControls extends StatefulWidget {
  const VideoControls({
    required this.controller,
    this.showMuteButton = true,
    Key? key,
  }) : super(key: key);

  final VideoController controller;
  final bool showMuteButton;

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  VideoController? videoPlayerController;
  late PlayerState playerState;
  late bool wasAlreadyPlaying;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<double>? _volumeSubscription;
  final position = ValueNotifier(Duration.zero);
  bool _playingBeforeLongPress = false;
  bool _currentlyWithinLongPress = false;
  final _mutex = Mutex();
  final _clipRRectKey =
      GlobalKey(debugLabel: '_VideoControlsState._clipRRectKey');
  int _lastGoodDurationInMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    videoPlayerController = widget.controller;
    _playingSubscription =
        videoPlayerController?.player.stream.playing.listen(_onVideoUpdate);
    _positionSubscription =
        videoPlayerController?.player.stream.position.listen(_onVideoUpdate);
    _durationSubscription =
        videoPlayerController?.player.stream.duration.listen(_onVideoUpdate);
    _volumeSubscription =
        videoPlayerController?.player.stream.volume.listen(_onVideoUpdate);
    playerState = videoPlayerController?.player.state ?? const PlayerState();
    position.value = playerState.position;
    wasAlreadyPlaying = playerState.playing;
    Future.delayed(_positionUpdatePeriod, _updatePosition);
  }

  String formatDuration(Duration d) {
    final seconds = (d.inMilliseconds / 1000).round();
    return '${(seconds / 60).floor()}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void _onVideoUpdate(Object _) {
    if (!mounted) {
      return;
    }

    final currentPlayerState = videoPlayerController?.player.state;
    final duration = currentPlayerState?.duration ?? Duration.zero;

    if (duration > Duration.zero) {
      _lastGoodDurationInMilliseconds = duration.inMilliseconds;
    }

    if (currentPlayerState != null) {
      setState(() {
        playerState = currentPlayerState;
      });
    }
  }

  Future<void> _updatePosition() async {
    if (!mounted) {
      return;
    }
    if (!_currentlyWithinLongPress) {
      final newPosition = videoPlayerController?.player.state.position;
      if (newPosition != null) {
        position.value = newPosition;
      }
    }
    Future.delayed(_positionUpdatePeriod, _updatePosition);
  }

  Future<void> _onLongPressStart() => _mutex.protect(() async {
        _playingBeforeLongPress = playerState.playing;
        _currentlyWithinLongPress = true;
      });

  Future<void> _onLongPressUpdate(double relativePosition) async {
    if (_currentlyWithinLongPress) {
      final newPosition = Duration(
          milliseconds:
              (relativePosition.clamp(0, 1) * _lastGoodDurationInMilliseconds)
                  .round());
      if (!_mutex.isLocked) {
        await _mutex.protect(() async {
          position.value = newPosition;
          await videoPlayerController?.player.seek(newPosition);
          await videoPlayerController?.player.play();
          await videoPlayerController?.player.pause();
          await Future.delayed(const Duration(milliseconds: 50));
        });
      }
    }
  }

  Future<void> _onLongPressEnd() => _mutex.protect(() async {
        if (_playingBeforeLongPress) {
          await videoPlayerController?.player.play();
        }
        _currentlyWithinLongPress = false;
      });

  double _calculateSliderWidth() {
    return (_clipRRectKey.currentContext?.findRenderObject() as RenderBox?)
            ?.paintBounds
            .width ??
        MediaQuery.sizeOf(context).width;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(50, 50, 50, 0.50),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon((_currentlyWithinLongPress
                        ? _playingBeforeLongPress
                        : playerState.playing)
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_arrow_solid),
                onPressed: () async {
                  if (playerState.playing) {
                    await videoPlayerController?.player.pause();
                  } else {
                    await videoPlayerController?.player.play();
                  }
                },
                color: Colors.white,
              ),
              ValueListenableBuilder(
                valueListenable: position,
                builder: (context, Duration positionValue, _) => SizedBox(
                  width: 40,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatDuration(positionValue),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTapUp: (x) async {
                      await _onLongPressStart();
                      await _onLongPressUpdate(
                          x.localPosition.dx / _calculateSliderWidth());
                      await _onLongPressEnd();
                    },
                    onHorizontalDragStart: (x) => _onLongPressStart(),
                    onHorizontalDragUpdate: (x) => _onLongPressUpdate(
                        x.localPosition.dx / _calculateSliderWidth()),
                    onHorizontalDragEnd: (x) => _onLongPressEnd(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      key: _clipRRectKey,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: position,
                            builder: (context, Duration positionValue, _) =>
                                LinearProgressIndicator(
                              minHeight: 44,
                              value: positionValue.inMilliseconds /
                                  playerState.duration.inMilliseconds
                                      .clamp(1, double.maxFinite),
                              valueColor: AlwaysStoppedAnimation(
                                  CupertinoColors.white.withOpacity(0.2)),
                              backgroundColor: CupertinoColors.systemFill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatDuration(playerState.duration),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    _volumeSubscription?.cancel();
  }
}
