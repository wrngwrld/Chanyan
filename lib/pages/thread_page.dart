import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_chan/pages/media_page.dart';
import 'package:flutter_chan/widgets/webm_player.dart';

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

  List<String> names = [];

  getAllMedia() async {
    List<Post> posts = await fetchPosts(widget.board, widget.thread);

    for (Post post in posts) {
      if (post.tim != null) {
        String video = post.tim.toString() + post.ext.toString();

        names.add(post.filename + post.ext);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.threadName),
      ),
      body: FutureBuilder(
        future: fetchPosts(widget.board, widget.thread),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.green,
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            snapshot.data[i].filename != null
                                ? SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 0, 8, 16),
                                      child: InkWell(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              // builder: (context) =>
                                              //     VideoListView(
                                              //   startVideo: i,
                                              //   names: names,
                                              //   list: media,
                                              //   video: snapshot
                                              //           .posts[i].tim
                                              //           .toString() +
                                              //       snapshot.data[i].ext
                                              //           .toString(),
                                              //   ext: snapshot.data[i].ext
                                              //       .toString(),
                                              //   board: board,
                                              //   height:
                                              //       snapshot.data[i].h,
                                              //   width: snapshot.data[i].w,
                                              // ),
                                              builder: (context) => MediaPage(
                                                video: snapshot.data[i].tim
                                                        .toString() +
                                                    snapshot.data[i].ext
                                                        .toString(),
                                                ext: snapshot.data[i].ext
                                                    .toString(),
                                                board: widget.board,
                                                height: snapshot.data[i].h,
                                                width: snapshot.data[i].w,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    snapshot.data[i].filename != null
                                        ? Text(
                                            snapshot.data[i].filename
                                                    .toString() +
                                                snapshot.data[i].ext.toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Container(),
                                    Text(
                                      'No.' + snapshot.data[i].no.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    snapshot.data[i].com != null
                                        ? Html(
                                            data:
                                                snapshot.data[i].com.toString(),
                                          )
                                        : Container(),
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
