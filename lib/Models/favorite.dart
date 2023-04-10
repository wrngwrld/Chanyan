class Favorite {
  Favorite({
    this.no,
    this.sub,
    this.com,
    this.imageUrl,
    this.board,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      no: json['no'] as int?,
      sub: json['sub'] as String?,
      com: json['com'] as String?,
      imageUrl: json['imageUrl'] as String?,
      board: json['board'] as String?,
    );
  }

  int? no;
  String? sub;
  String? com;
  String? imageUrl;
  String? board;

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
