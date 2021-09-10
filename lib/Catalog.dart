import 'package:flutter/material.dart';
import 'package:flutter_chan/Models/CatalogModel.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'Thread.dart';

class Catalog extends StatelessWidget {
  const Catalog({
    @required this.id,
    @required this.name,
  });

  final id;
  final name;

  Future<List<CatalogModel>> makeGetRequest() async {
    final url = Uri.parse('https://a.4cdn.org/$id/catalog.json');
    Response response = await get(url);
    // print('Status code: ${response.statusCode}');
    // print('Headers: ${response.headers}');
    // print('Body: ${response.body}');

    final catalog = catalogModelFromJson(response.body);

    return catalog;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('/' + name + '/'),
      ),
      body: FutureBuilder(
        future: makeGetRequest(),
        builder:
            (BuildContext context, AsyncSnapshot<List<CatalogModel>> snapshot) {
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
                  for (CatalogModel catalog in snapshot.data)
                    for (ThreadCatalogModel thread in catalog.threads)
                      InkWell(
                        onTap: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Thread(
                                threadName: thread.sub != null
                                    ? thread.sub.toString()
                                    : thread.com.toString(),
                                id: thread.no,
                                board: id,
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
                              thread.tim != null
                                  ? SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            'https://i.4cdn.org/$id/' +
                                                thread.tim.toString() +
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No.' + thread.no.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      thread.sub != null
                                          ? Text(
                                              thread.sub.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          : Container(),
                                      thread.com != null
                                          ? Html(
                                              data: thread.com.toString(),
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
