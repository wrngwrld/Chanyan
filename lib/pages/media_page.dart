import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/media.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/blocs/gallery_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/widgets/video_controls.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import '../API/api.dart';
import '../API/save_videos.dart';
import '../blocs/saved_attachments_model.dart';

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MediaPage extends StatefulWidget {
  const MediaPage({
    Key? key,
    required this.video,
    this.board,
    required this.allPosts,
    this.isAsset = false,
    this.directory,
  }) : super(key: key);

  final String video;
  final String? board;
  final List<Post> allPosts;
  final bool isAsset;
  final Directory? directory;

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late PageController pageController;

  List<MediaMetadata> mediaList = [];

  final early = HashSet<int>();

  late final players = HashMap<int, Player>();
  late final controllers = HashMap<int, VideoController>();

  bool isSaved = false;
  int index = 0;

  @override
  void initState() {
    for (final Post post in widget.allPosts) {
      if (post.tim != null) {
        mediaList.add(
          MediaMetadata(
            videoId: post.tim ?? 0,
            videoName: post.tim.toString() + post.ext.toString(),
            fileName: post.filename ?? '',
            ext: post.ext ?? '',
          ),
        );
      }
    }

    index = mediaList.indexWhere(
      (element) => element.videoName == widget.video,
    );

    pageController = PageController(
      initialPage: index,
      keepPage: false,
    );

    Future.wait([
      if (index > 0 && index - 1 >= 0) createPlayer(index - 1),
      createPlayer(index),
      if (index < mediaList.length) createPlayer(index + 1),
    ]).then((_) {
      players[index]?.play();
    });

    super.initState();
  }

  @override
  void dispose() {
    for (final player in players.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> createPlayer(int page) async {
    final player = Player();
    final controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(),
    );
    await player.setPlaylistMode(PlaylistMode.loop);

    await player.open(
      Media(
        widget.isAsset
            ? '${widget.directory!.path}/savedAttachments/${getNameWithoutExtension(mediaList[page].fileName)}${mediaList[page].ext}'
            : 'https://i.4cdn.org/${widget.board}/${mediaList[page].videoName}',
      ),
      play: false,
    );
    players[page] = player;
    controllers[page] = controller;

    if (early.contains(page)) {
      early.remove(page);
      setState(() {});
    }
  }

  bool isVideo(String ext) {
    return ext == '.mp4' || ext == '.webm' || ext == '.mkv';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final gallery = Provider.of<GalleryProvider>(context);
    final savedAttachments = Provider.of<SavedAttachmentsProvider>(context);

    isSaved = false;
    for (final element in savedAttachments.getSavedAttachments()) {
      final String videoBaseName = mediaList[index].videoName.split('.').first;
      final String fileBaseName = element.fileName!.split('.').first;

      if (fileBaseName == videoBaseName) {
        isSaved = true;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.getTheme() == ThemeData.light()
          ? CupertinoColors.systemGroupedBackground
          : CupertinoColors.black,
      extendBodyBehindAppBar: true,
      appBar: gallery.getControlsVisible()
          ? CupertinoNavigationBar(
              backgroundColor: theme.getTheme() == ThemeData.light()
                  ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
                  : CupertinoColors.black.withOpacity(0.7),
              border: Border.all(color: Colors.transparent),
              leading: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Transform.translate(
                  offset: const Offset(-16, 0),
                  child: CupertinoNavigationBarBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              middle: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Column(
                  children: [
                    Text(
                      '${mediaList[index].fileName}${widget.isAsset ? '' : mediaList[index].ext}',
                      style: TextStyle(
                        color: theme.getTheme() == ThemeData.dark()
                            ? Colors.white
                            : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${index + 1}/${mediaList.length}',
                      style: TextStyle(
                        color: theme.getTheme() == ThemeData.dark()
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSaved)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.bookmark),
                      onPressed: () => {
                        savedAttachments.addSavedAttachments(
                          _scaffoldKey.currentContext ?? context,
                          widget.board ?? '',
                          mediaList[index].videoName,
                        )
                      },
                    )
                  else
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.bookmark_fill),
                      onPressed: () => {
                        showCupertinoDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return CupertinoAlertDialog(
                                  title: const Text('Delete Attachment?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                      onPressed: () => {
                                        Navigator.pop(context),
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                      onPressed: () => {
                                        savedAttachments
                                            .removeSavedAttachments(
                                                mediaList[index].videoName,
                                                context)
                                            .then(
                                              (value) => {
                                                Navigator.pop(context),
                                              },
                                            ),
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      },
                    ),
                  SizedBox(
                    width: 20,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            actions: [
                              if (!isSaved)
                                CupertinoActionSheetAction(
                                  child: const Text('Open in Browser'),
                                  onPressed: () {
                                    launchURL(
                                      'https://i.4cdn.org/${widget.board}/${mediaList[index].videoName}',
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              CupertinoActionSheetAction(
                                child: const Text('Share'),
                                onPressed: () {
                                  shareMedia(
                                    'https://i.4cdn.org/${widget.board}/${mediaList[index].videoName}',
                                    mediaList[index].videoName,
                                    _scaffoldKey.currentContext ?? context,
                                    isSaved: isSaved,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Download'),
                                onPressed: () {
                                  saveVideo(
                                    'https://i.4cdn.org/${widget.board}/${mediaList[index].videoName}',
                                    mediaList[index].videoName,
                                    _scaffoldKey.currentContext ?? context,
                                    showSnackBar: true,
                                    isSaved: isSaved,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.ios_share),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: PageView.builder(
        onPageChanged: (i) {
          index = i;

          gallery.setCurrentPage(i);
          gallery.setCurrentMedia(mediaList[i].videoName);

          if (isVideo(mediaList[i].ext)) {
            players[i]?.play();
          }

          // Dispose the [Player]s & [VideoController]s of the pages that are not visible & not adjacent to the current page.
          players.removeWhere(
            (page, player) {
              final remove = ![i, i - 1, i + 1].contains(page);
              if (remove) {
                player.dispose();
              }
              return remove;
            },
          );
          controllers.removeWhere(
            (page, controller) {
              final remove = ![i, i - 1, i + 1].contains(page);
              return remove;
            },
          );

          // Pause other pages' videos.
          for (final e in players.entries) {
            if (e.key != i) {
              e.value.pause();
              e.value.seek(Duration.zero);
            }
          }

          // Create the [Player]s & [VideoController]s for the next & previous page.
          // It is obvious that current page's [Player] & [VideoController] will already exist, still checking it redundantly
          if (!players.containsKey(i)) {
            createPlayer(i);
          }
          if (!players.containsKey(i + 1) && i + 1 < mediaList.length) {
            createPlayer(i + 1);
          }
          if (!players.containsKey(i - 1) && i - 1 >= 0) {
            createPlayer(i - 1);
          }
        },
        itemCount: mediaList.length,
        itemBuilder: (context, i) {
          if (isVideo(mediaList[i].ext)) {
            final controller = controllers[i];
            if (controller == null) {
              early.add(i);
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xffffffff),
                ),
              );
            }

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
          } else {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: widget.isAsset
                    ? Image.file(
                        File(
                          '${widget.directory!.path}/savedAttachments/${mediaList[i].fileName}',
                        ),
                      )
                    : Image.network(
                        'https://i.4cdn.org/${widget.board}/${mediaList[i].videoName}'),
              ),
            );
          }
        },
        controller: pageController,
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
