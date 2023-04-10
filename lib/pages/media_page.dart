import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/blocs/gallery_model.dart';
import 'package:flutter_chan/blocs/saved_attachments_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MediaPage extends StatefulWidget {
  const MediaPage({
    Key? key,
    required this.video,
    this.board,
    required this.list,
    required this.fileNames,
  }) : super(key: key);

  final String video;
  final String? board;

  final List<Widget> list;
  final List<String> fileNames;

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late PreloadPageController controller;

  final String page = '0';
  late int index;
  String currentName = '';
  bool isSaved = false;

  void onPageChanged(int i, String media, GalleryProvider gallery) {
    gallery.setCurrentPage(i);
    gallery.setCurrentMedia(media);

    setState(() {
      index = i;
    });
  }

  Future<void> setStartVideo(String video) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('startVideo', video);
  }

  @override
  void initState() {
    super.initState();

    index = widget.fileNames.indexWhere((element) => element == widget.video);

    if (index < 0) {
      Navigator.of(context).pop();
    }

    setStartVideo(getNameWithoutExtension(widget.fileNames[index]));

    controller = PreloadPageController(
      initialPage: index,
      keepPage: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final gallery = Provider.of<GalleryProvider>(context);
    final savedAttachments = Provider.of<SavedAttachmentsProvider>(context);

    isSaved = false;
    for (final element in savedAttachments.getSavedAttachments()) {
      if (element.fileName == widget.fileNames[index]) {
        isSaved = true;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.getTheme() == ThemeData.light()
          ? CupertinoColors.systemGroupedBackground
          : CupertinoColors.black,
      extendBodyBehindAppBar: true,
      appBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        border: Border.all(color: Colors.transparent),
        middle: Column(
          children: [
            Text(
              widget.fileNames[index],
              style: TextStyle(
                color: theme.getTheme() == ThemeData.dark()
                    ? Colors.white
                    : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${index + 1}/${widget.list.length}',
              style: TextStyle(
                color: theme.getTheme() == ThemeData.dark()
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
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
                    widget.fileNames[index],
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
                                          widget.fileNames[index])
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
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: [
                        if (!isSaved)
                          CupertinoActionSheetAction(
                            child: const Text('Open in Browser'),
                            onPressed: () {
                              launchURL(
                                'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                              );
                              Navigator.pop(context);
                            },
                          ),
                        CupertinoActionSheetAction(
                          child: const Text('Share'),
                          onPressed: () {
                            shareMedia(
                              'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                              widget.fileNames[index],
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
                              'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
                              widget.fileNames[index],
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
      ),
      body: PreloadPageView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        children: widget.list,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (i) => onPageChanged(i, widget.fileNames[i], gallery),
        preloadPagesCount: 2,
      ),
    );
  }
}
