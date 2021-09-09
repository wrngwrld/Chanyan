import 'package:flutter/material.dart';
import 'package:flutter_chan/VideoPlayer.dart';
import 'package:flutter_chan/VideoView.dart';
import 'package:http/http.dart';

import 'Models/ThreadModel.dart';

class Thread extends StatelessWidget {
  const Thread({
    @required this.id,
    @required this.name,
  });

  final id;
  final name;

  static const urlPrefix = 'https://a.4cdn.org/gif/thread';

  Future<ThreadModel> makeGetRequest() async {
    final url = Uri.parse('$urlPrefix/$id.json');
    Response response = await get(url);
    print('Status code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    final threadModel = threadModelFromJson(response.body);

    return threadModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
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
              return ListView(
                children: [
                  for (Post post in snapshot.data.posts)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          post.filename != null
                              ? SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoView(
                                              video: post.filename.toString() +
                                                  post.ext.toString(),
                                            ),
                                          ),
                                        )
                                      },
                                      child: Container(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.filename.toString() + post.ext.toString(),
                              ),
                              Text(
                                'No.' + post.no.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ],
              );
          }
        },
      ),
    );
  }
}
