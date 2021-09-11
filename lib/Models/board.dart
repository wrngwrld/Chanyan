class Board {
  Board({
    this.board,
    this.title,
    this.wsBoard,
    this.perPage,
    this.pages,
    this.maxFileSize,
    this.maxWebmFileSize,
    this.maxCommentChars,
    this.maxWebmDuration,
    this.bumpLimit,
    this.imageLimit,
    this.threadsCooldown,
    this.repliesCooldown,
    this.imagesCooldown,
    this.metaDescription,
    this.isArchived,
    this.forcedAnon,
    this.countryFlags,
    this.userIds,
    this.spoilers,
    this.customSpoilers,
  });

  final String board;
  final String title;
  final int wsBoard;
  final int perPage;
  final int pages;
  final int maxFileSize;
  final int maxWebmFileSize;
  final int maxCommentChars;
  final int maxWebmDuration;
  final int bumpLimit;
  final int imageLimit;
  final int threadsCooldown;
  final int repliesCooldown;
  final int imagesCooldown;
  final String metaDescription;
  final int isArchived;
  final int forcedAnon;
  final int countryFlags;
  final int userIds;
  final int spoilers;
  final int customSpoilers;

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      board: json['board'],
      title: json['title'],
      wsBoard: json['ws_board'],
      perPage: json['per_page'],
      pages: json['pages'],
      maxFileSize: json['max_filesize'],
      maxWebmFileSize: json['max_webm_filesize'],
      maxCommentChars: json['max_comment_chars'],
      maxWebmDuration: json['max_webm_duration'],
      bumpLimit: json['bump_limit'],
      imageLimit: json['image_limit'],
      threadsCooldown: json['cooldowns']['threads'],
      repliesCooldown: json['cooldowns']['replies'],
      imagesCooldown: json['cooldowns']['images'],
      metaDescription: json['meta_description'],
      isArchived: json['is_archived'],
      forcedAnon: json['forced_anon'],
      countryFlags: json['country_flags'],
      userIds: json['user_ids'],
      spoilers: json['spoilers'],
      customSpoilers: json['custom_spoilers'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'title': title,
      'ws_board': wsBoard,
    };
  }
}
