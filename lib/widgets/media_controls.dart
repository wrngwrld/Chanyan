import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class MediaControls extends StatefulWidget {
  const MediaControls({
    Key? key,
    required this.player,
  }) : super(key: key);

  final Player player;

  @override
  State<MediaControls> createState() => MediaControlsState();
}

class MediaControlsState extends State<MediaControls> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 45,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  // The BackdropFilter is currently bugged in flutter, it will not cut the border radius
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.player.playOrPause();
                      },
                      icon: StreamBuilder(
                        stream: widget.player.stream.playing,
                        builder: (context, playing) => Icon(
                          color: Colors.white,
                          playing.data == true ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                          stream: widget.player.stream.position,
                          builder: (context, position) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  position.data.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: widget.player.stream.duration,
                                  builder: (context, duration) => Expanded(
                                    child: Slider(
                                      activeColor: CupertinoColors.systemGrey,
                                      inactiveColor: CupertinoColors.systemFill,
                                      thumbColor: CupertinoColors.white,
                                      value:
                                          position.data!.inSeconds.toDouble(),
                                      min: 0.0,
                                      max: duration.data!.inSeconds.toDouble(),
                                      onChanged: (double value) {
                                        widget.player.seek(
                                          Duration(
                                            seconds: value.toInt(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.player.state.duration.inSeconds
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                )
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
