import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/save_videos.dart';
import 'package:flutter_chan/Models/saved_attachment.dart';
import 'package:flutter_chan/blocs/saved_attachments_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:provider/provider.dart';

class SavedAttachments extends StatefulWidget {
  const SavedAttachments({Key? key}) : super(key: key);

  @override
  State<SavedAttachments> createState() => _SavedAttachmentsState();
}

class _SavedAttachmentsState extends State<SavedAttachments> {
  final ScrollController scrollController = ScrollController();

  List<Widget> media = [];
  List<String> fileNames = [];

  Directory directory = Directory('');

  Future<List<SavedAttachment>> getSavedAttachments() async {
    directory = await requestDirectory(directory);

    final savedAttachments =
        Provider.of<SavedAttachmentsProvider>(context, listen: false);
    final List<SavedAttachment> savedAttachmentList =
        savedAttachments.getSavedAttachments();

    getAllMedia(savedAttachmentList);

    return Future.value(savedAttachmentList);
  }

  Future<void> getAllMedia(List<SavedAttachment> savedAttachments) async {
    media = [];
    fileNames = [];

    for (final SavedAttachment savedAttachment in savedAttachments) {
      final String video = savedAttachment.fileName!.split('/').last;

      final String ext =
          savedAttachment.fileName!.split('/').last.split('.').last;

      fileNames.add(video);
      media.add(
        ext == 'webm'
            ? VLCPlayer(
                video:
                    '${getNameWithoutExtension(savedAttachment.fileName ?? "")}.mp4',
                isAsset: true,
                fileName:
                    '${getNameWithoutExtension(savedAttachment.fileName ?? "")}.mp4',
                directory: directory,
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.asset(
                  '${directory.path}/savedAttachments/${savedAttachment.fileName}',
                ),
              ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final savedAttachments = Provider.of<SavedAttachmentsProvider>(context);

    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground
            : CupertinoColors.black,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              leading: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Transform.translate(
                  offset: const Offset(-16, 0),
                  child: CupertinoNavigationBarBackButton(
                    previousPageTitle: 'Home',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              previousPageTitle: 'Home',
              border: Border.all(color: Colors.transparent),
              largeTitle: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: MediaQuery.textScaleFactorOf(context),
                ),
                child: Text(
                  'Saved Attachments',
                  style: TextStyle(
                    color: theme.getTheme() == ThemeData.dark()
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
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
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text('Clear bookmarks'),
                                onPressed: () {
                                  savedAttachments.clearSavedAttachments();
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
              backgroundColor: theme.getTheme() == ThemeData.light()
                  ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
                  : CupertinoColors.black.withOpacity(0.7),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (savedAttachments.getSavedAttachments().isEmpty)
                    Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Save Attachments first!',
                          style: TextStyle(
                            fontSize: 26,
                            color: theme.getTheme() == ThemeData.dark()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        FutureBuilder<List<SavedAttachment>>(
                            future: getSavedAttachments(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<SavedAttachment>> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  return SizedBox(
                                    child: GridView.count(
                                      physics: const ScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      crossAxisCount: 3,
                                      children: [
                                        for (final SavedAttachment attachment
                                            in snapshot.data ?? [])
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MediaPage(
                                                    video:
                                                        attachment.fileName ??
                                                            '',
                                                    list: media,
                                                    fileNames: fileNames,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    '${directory.path}/savedAttachments/${attachment.thumbnail}',
                                                  ),
                                                ),
                                              ),
                                              child: attachment
                                                          .savedAttachmentType ==
                                                      'Video'
                                                  ? Center(
                                                      child: Icon(
                                                        CupertinoIcons.play,
                                                        color: Colors.white,
                                                        size: 50,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 10,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .6),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ),
                                          )
                                      ],
                                    ),
                                  );
                              }
                            }),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
