import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:provider/provider.dart';

class ThreadGridView extends StatefulWidget {
  const ThreadGridView({
    Key key,
    @required this.media,
    @required this.fileNames,
    @required this.board,
    @required this.tims,
    @required this.prevTitle,
  }) : super(key: key);

  final List<Widget> media;
  final List<String> fileNames;
  final List<int> tims;
  final String board;
  final String prevTitle;

  @override
  State<ThreadGridView> createState() => _ThreadGridViewState();
}

class _ThreadGridViewState extends State<ThreadGridView> {
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      backgroundColor: theme.getTheme() == ThemeData.light()
          ? CupertinoColors.systemGroupedBackground
          : Colors.black,
      appBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        previousPageTitle: '${widget.prevTitle.substring(0, 9)}...',
        border: Border.all(color: Colors.transparent),
        middle: const Text(
          'Media Gallery',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(Icons.download),
              onPressed: () => {
                saveAllMedia(
                  'https://i.4cdn.org/${widget.board}/',
                  widget.fileNames,
                  context,
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
                        CupertinoActionSheetAction(
                          child: const Text('1 Columns'),
                          onPressed: () {
                            setState(() {
                              axisCount = 1;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text('2 Columns'),
                          onPressed: () {
                            setState(() {
                              axisCount = 2;
                            });

                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text('3 Columns'),
                          onPressed: () {
                            setState(() {
                              axisCount = 3;
                            });

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
                child: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axisCount,
        ),
        children: [
          for (int i = 0; i < widget.tims.length; i++)
            GestureDetector(
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MediaPage(
                      video: widget.fileNames[i],
                      board: widget.board,
                      list: widget.media,
                      fileNames: widget.fileNames,
                    ),
                  ),
                ),
              },
              child: widget.fileNames[i].contains('jpg') ||
                      widget.fileNames[i].contains('png')
                  ? Image.network(
                      'https://i.4cdn.org/${widget.board}/${widget.tims[i]}.jpg',
                      fit: BoxFit.cover,
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://i.4cdn.org/${widget.board}/${widget.tims[i]}s.jpg',
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            CupertinoIcons.play,
                            color: Colors.white,
                            size: 50,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
