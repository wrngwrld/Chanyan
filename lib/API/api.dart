import 'dart:convert';

import 'package:flutter_chan/Models/board.dart';
import 'package:flutter_chan/Models/post.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

Future<List<Post>> fetchAllThreadsFromBoard(Sort sorting, String board) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/catalog.json'));

  final List<Post> ops = List.empty(growable: true);
  final List pages = jsonDecode(response.body) as List;

  if (response.statusCode == 200) {
    for (final page in pages) {
      final List opsInPage = page['threads'] as List;
      for (final opInPage in opsInPage) {
        ops.add(Post.fromJson(opInPage));
      }
    }

    // Thread sorting
    if (sorting != null) {
      switch (sorting) {
        case Sort.byBumpOrder:
          ops.sort((a, b) {
            return a.lastModified.compareTo(b.lastModified);
          });
          break;
        case Sort.byReplyCount:
          ops.sort((a, b) {
            return b.replies.compareTo(a.replies);
          });
          break;
        case Sort.byImagesCount:
          ops.sort((a, b) {
            return b.images.compareTo(a.images);
          });
          break;
        case Sort.byNewest:
          ops.sort((a, b) {
            return b.time.compareTo(a.time);
          });
          break;
        case Sort.byOldest:
          ops.sort((a, b) {
            return a.time.compareTo(b.time);
          });
          break;
      }
    }

    return ops;
  } else {
    throw Exception('Failed to load OPs.');
  }
}

Future<List<Post>> fetchAllPostsFromThread(String board, int thread) async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/$board/thread/$thread.json'));

  if (response.statusCode == 200) {
    final List<Post> posts = (jsonDecode(response.body)['posts'] as List)
        .map((model) => Post.fromJson(model))
        .toList();

    return posts;
  } else {
    throw Exception('Failed to load posts.');
  }
}

Future<List<Post>> fetchAllRepliesToPost(
  int post,
  String board,
  int thread,
  List<Post> allPosts,
) async {
  final List<Post> list = [];

  for (final Post postLoop in allPosts) {
    if (postLoop.com != null) {
      final document = parse(postLoop.com);

      if (document.body.text.contains(post.toString())) {
        list.add(postLoop);
      }
    }
  }

  return list;
}

Future<List<Board>> fetchAllBoards() async {
  final Response response =
      await get(Uri.parse('https://a.4cdn.org/boards.json'));

  if (response.statusCode == 200) {
    final List<Board> boards = (jsonDecode(response.body)['boards'] as List)
        .map((model) => Board.fromJson(model))
        .toList();
    return boards;
  } else {
    throw Exception('Failed to load boards.');
  }
}

Future<Post> fetchPost(String board, int thread, int post) async {
  final List<Post> allPosts = await fetchAllPostsFromThread(board, thread);

  for (final Post postLoop in allPosts) {
    if (postLoop.no == post) {
      return postLoop;
    }
  }

  return null;
}

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}
