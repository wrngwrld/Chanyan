import 'package:flutter_chan/models/post.dart';

class Favorite {
  Favorite({
    this.posts,
    this.boards,
  });

  List<Post> posts = [];
  List<String> boards = [];

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      posts: json['posts'],
      boards: json['boards'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'posts': posts,
      'boards': boards,
    };
  }
}
