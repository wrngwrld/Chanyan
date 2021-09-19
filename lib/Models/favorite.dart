class Favorite {
  Favorite({
    this.no,
    this.sub,
    this.replies,
    this.images,
    this.com,
    this.imageUrl,
    this.board,
  });

  int no;
  String sub;
  int replies;
  int images;
  String com;
  String imageUrl;
  String board;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      no: json['no'],
      sub: json['sub'],
      replies: json['replies'],
      images: json['images'],
      com: json['com'],
      imageUrl: json['imageUrl'],
      board: json['board'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'sub': sub,
      'replies': replies,
      'images': images,
      'com': com,
      'imageUrl': imageUrl,
      'board': board,
    };
  }
}
