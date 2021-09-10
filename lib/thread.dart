import 'package:flutter/material.dart';
import 'package:flutter_chan/VideoView.dart';
import 'package:flutter_chan/vlcPlayer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';

import 'Models/ThreadModel.dart';
import 'VideoListView.dart';

class Thread extends StatelessWidget {
  Thread({
    @required this.board,
    @required this.id,
    @required this.threadName,
  });

  final board;
  final id;
  final threadName;

  List<Widget> media = [];
  List<String> names = [];

  getAllMedia() async {
    ThreadModel threadModel = await makeGetRequest();

    for (Post post in threadModel.posts) {
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
              : Image.network('https://i.4cdn.org/$board/$video'),
        );
      }
    }
  }

  Future<ThreadModel> makeGetRequest() async {
    final url = Uri.parse('https://a.4cdn.org/$board/thread/$id.json');
    Response response = await get(url);

    final threadModel = threadModelFromJson(response.body);

    return threadModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(threadName),
      ),
      body: FutureBuilder(
        future: makeGetRequest(),
        builder: (BuildContext context, AsyncSnapshot<ThreadModel> snapshot) {
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
                  for (int i = 0; i < snapshot.data.posts.length; i++)
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
                            snapshot.data.posts[i].filename != null
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
                                              //           .data.posts[i].tim
                                              //           .toString() +
                                              //       snapshot.data.posts[i].ext
                                              //           .toString(),
                                              //   ext: snapshot.data.posts[i].ext
                                              //       .toString(),
                                              //   board: board,
                                              //   height:
                                              //       snapshot.data.posts[i].h,
                                              //   width: snapshot.data.posts[i].w,
                                              // ),
                                              builder: (context) => VideoView(
                                                video: snapshot
                                                        .data.posts[i].tim
                                                        .toString() +
                                                    snapshot.data.posts[i].ext
                                                        .toString(),
                                                ext: snapshot.data.posts[i].ext
                                                    .toString(),
                                                board: board,
                                                height:
                                                    snapshot.data.posts[i].h,
                                                width: snapshot.data.posts[i].w,
                                              ),
                                            ),
                                          )
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            'https://i.4cdn.org/$board/' +
                                                snapshot.data.posts[i].tim
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
                                    snapshot.data.posts[i].filename != null
                                        ? Text(
                                            snapshot.data.posts[i].filename
                                                    .toString() +
                                                snapshot.data.posts[i].ext
                                                    .toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Container(),
                                    Text(
                                      'No.' +
                                          snapshot.data.posts[i].no.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    snapshot.data.posts[i].com != null
                                        ? Html(
                                            data: snapshot.data.posts[i].com
                                                .toString(),
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
