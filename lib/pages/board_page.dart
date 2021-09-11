import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/models/post.dart';
import 'package:flutter_chan/pages/thread_page.dart';
import 'package:flutter_html/flutter_html.dart';

class BoardPage extends StatefulWidget {
  BoardPage({
    @required this.board,
    @required this.name,
  });

  final board;
  final name;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  Sort sortBy = Sort.byImagesCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('/' + widget.name + '/'),
        actions: [
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Sort by bump order"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by reply count"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by image count"),
                      value: 2,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by newest"),
                      value: 3,
                    ),
                    PopupMenuItem(
                      child: Text("Sort by oldest"),
                      value: 4,
                    ),
                  ],
              onSelected: (result) {
                switch (result) {
                  case 0:
                    setState(() {
                      sortBy = Sort.byBumpOrder;
                    });
                    break;
                  case 1:
                    setState(() {
                      sortBy = Sort.byReplyCount;
                    });

                    break;
                  case 2:
                    setState(() {
                      sortBy = Sort.byImagesCount;
                    });

                    break;
                  case 3:
                    setState(() {
                      sortBy = Sort.byNewest;
                    });

                    break;
                  case 4:
                    setState(() {
                      sortBy = Sort.byOldest;
                    });

                    break;
                  default:
                }
              })
        ],
      ),
      body: FutureBuilder(
        future: fetchOPs(sortBy, widget.board),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
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
                  for (Post post in snapshot.data)
                    // for (ThreadCatalogModel thread in catalog.threads)
                    InkWell(
                      onTap: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ThreadPage(
                              threadName: post.sub != null
                                  ? post.sub.toString()
                                  : post.com.toString(),
                              thread: post.no,
                              board: widget.board,
                            ),
                          ),
                        )
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.15,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            post.tim != null
                                ? SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://i.4cdn.org/${widget.board}/' +
                                              post.tim.toString() +
                                              's.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No.' + post.no.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    post.sub != null
                                        ? Text(
                                            post.sub.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : Container(),
                                    post.com != null
                                        ? Html(
                                            data: post.com.toString(),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
