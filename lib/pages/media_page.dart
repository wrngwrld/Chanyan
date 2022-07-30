import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/blocs/gallery_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({
    Key key,
    @required this.video,
    @required this.ext,
    @required this.board,
    @required this.height,
    @required this.width,
    @required this.list,
    @required this.names,
    @required this.fileNames,
  }) : super(key: key);

  final String video;
  final String ext;
  final String board;
  final int height;
  final int width;

  final List<Widget> list;
  final List<String> names;
  final List<String> fileNames;

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  PreloadPageController controller;

  final String page = '0';
  int index;
  String currentName = '';

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

    setStartVideo(widget.names[index]);

    controller = PreloadPageController(
      initialPage: index,
      keepPage: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final gallery = Provider.of<GalleryProvider>(context);

    return Scaffold(
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
              widget.names[index],
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
            SizedBox(
              width: 20,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: [
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
                            Share.share(
                              'https://i.4cdn.org/${widget.board}/${widget.fileNames[index]}',
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
                              context,
                              true,
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
