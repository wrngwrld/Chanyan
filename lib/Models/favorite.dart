class Favorite {
  Favorite({
    this.no,
    this.sub,
    this.com,
    this.imageUrl,
    this.board,
  });

  int no;
  String sub;
  String com;
  String imageUrl;
  String board;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      no: json['no'],
      sub: json['sub'],
      com: json['com'],
      imageUrl: json['imageUrl'],
      board: json['board'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'sub': sub,
      'com': com,
      'imageUrl': imageUrl,
      'board': board,
    };
  }
}
