import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:flutter_chan/widgets/webm_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThreadPage extends StatefulWidget {
  ThreadPage({
    @required this.board,
    @required this.thread,
    @required this.threadName,
  });

  final board;
  final thread;
  final threadName;

  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  List<Widget> media = [];
  List<String> fileNames = [];
  List<String> names = [];

  bool isFavorite = false;

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  getAllMedia() async {
    List<Post> posts = await fetchPosts(widget.board, widget.thread);

    for (Post post in posts) {
      if (post.tim != null) {
        String video = post.tim.toString() + post.ext.toString();

        names.add(post.filename + post.ext);
        fileNames.add(post.tim.toString() + post.ext);
        media.add(
          post.ext == '.webm'
              ? VLCPlayer(
                  video: video,
                  height: post.h,
                  width: post.w,
                )
              : Image.network('https://i.4cdn.org/${widget.board}/$video'),
        );
      }
    }
  }

  fetchFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    if (favoriteThreadsPrefs == null) favoriteThreadsPrefs = [];

    if (favoriteThreadsPrefs.contains('${widget.board},${widget.thread}')) {
      setState(() {
        isFavorite = true;
      });
    } else {
      setState(() {
        isFavorite = false;
      });
    }
  }

  setFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    if (favoriteThreadsPrefs == null) favoriteThreadsPrefs = [];

    favoriteThreadsPrefs.add('${widget.board},${widget.thread}');

    prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);

    setState(() {
      isFavorite = true;
    });
  }

  removeFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favoriteThreadsPrefs = prefs.getStringList('favoriteThreads');

    favoriteThreadsPrefs.remove('${widget.board},${widget.thread}');

    prefs.setStringList('favoriteThreads', favoriteThreadsPrefs);

    setState(() {
      isFavorite = false;
    });
  }

  @override
  void initState() {
    super.initState();

    fetchFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kGreen,
        foregroundColor: AppColors.kWhite,
        title: Text(widget.threadName),
        actions: [
          IconButton(
            onPressed: () => isFavorite ? removeFavorite() : setFavorite(),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
            ),
          ),
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Copy Link"),
                      value: 0,
                    ),
                  ],
              onSelected: (result) {
                String clipboardText =
                    'https://boards.4chan.org/${widget.board}/thread/${widget.thread}';

                if (result == 0) {
                  print(clipboardText);
                  Clipboard.setData(
                          new ClipboardData(text: clipboardText.toString()))
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Thread address copied to clipboard")));
                  });
                }
              })
        ],
      ),
      body: FutureBuilder(
        future: fetchPosts(widget.board, widget.thread),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: AppColors.kWhite,
                backgroundColor: AppColors.kGreen,
              );
              break;
            default:
              getAllMedia();
              return ListView(
                children: [
                  // for (Post post in snapshot.data.posts)
                  for (int i = 0; i < snapshot.data.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: .25,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                snapshot.data[i].filename != null
                                    ? SizedBox(
                                        width: 125,
                                        height: 125,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 16),
                                          child: InkWell(
                                            onTap: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MediaPage(
                                                    video: snapshot.data[i].tim
                                                            .toString() +
                                                        snapshot.data[i].ext
                                                            .toString(),
                                                    ext: snapshot.data[i].ext
                                                        .toString(),
                                                    board: widget.board,
                                                    height: snapshot.data[i].h,
                                                    width: snapshot.data[i].w,
                                                    startVideo: i,
                                                    names: names,
                                                    list: media,
                                                    fileNames: fileNames,
                                                  ),
                                                ),
                                              )
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                'https://i.4cdn.org/${widget.board}/' +
                                                    snapshot.data[i].tim
                                                        .toString() +
                                                    's.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        snapshot.data[i].filename != null
                                            ? Text(
                                                snapshot.data[i].ext
                                                        .toString() +
                                                    ' (' +
                                                    formatBytes(
                                                      snapshot.data[i].fsize,
                                                      0,
                                                    ) +
                                                    ')',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.kGreen,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Container(),
                                        snapshot.data[i].sub != null
                                            ? Text(
                                                snapshot.data[i].sub.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Container(),
                                        Text(
                                          'No.' +
                                              snapshot.data[i].no.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          snapshot.data[i].name.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 20,
                                ),
                              ],
                            ),
                            snapshot.data[i].com != null
                                ? Html(
                                    data: snapshot.data[i].com.toString(),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}
