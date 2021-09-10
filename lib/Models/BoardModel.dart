// To parse this JSON data, do
//
//     final boardModel = boardModelFromJson(jsonString);

import 'dart:convert';

BoardModel boardModelFromJson(String str) =>
    BoardModel.fromJson(json.decode(str));

String boardModelToJson(BoardModel data) => json.encode(data.toJson());

class BoardModel {
  BoardModel({
    this.boards,
  });

  List<Board> boards;

  factory BoardModel.fromJson(Map<String, dynamic> json) => BoardModel(
        boards: List<Board>.from(json["boards"].map((x) => Board.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "boards": List<dynamic>.from(boards.map((x) => x.toJson())),
      };
}

class Board {
  Board({
    this.board,
    this.title,
    this.wsBoard,
    this.perPage,
    this.pages,
    this.maxFilesize,
    this.maxWebmFilesize,
    this.maxCommentChars,
    this.maxWebmDuration,
    this.bumpLimit,
    this.imageLimit,
    this.cooldowns,
    this.metaDescription,
    this.isArchived,
    this.spoilers,
    this.customSpoilers,
    this.forcedAnon,
    this.userIds,
    this.countryFlags,
    this.codeTags,
    this.webmAudio,
    this.minImageWidth,
    this.minImageHeight,
    this.oekaki,
    this.sjisTags,
    this.boardFlags,
    this.textOnly,
    this.requireSubject,
    this.mathTags,
  });

  String board;
  String title;
  int wsBoard;
  int perPage;
  int pages;
  int maxFilesize;
  int maxWebmFilesize;
  int maxCommentChars;
  int maxWebmDuration;
  int bumpLimit;
  int imageLimit;
  Cooldowns cooldowns;
  String metaDescription;
  int isArchived;
  int spoilers;
  int customSpoilers;
  int forcedAnon;
  int userIds;
  int countryFlags;
  int codeTags;
  int webmAudio;
  int minImageWidth;
  int minImageHeight;
  int oekaki;
  int sjisTags;
  Map<String, String> boardFlags;
  int textOnly;
  int requireSubject;
  int mathTags;

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        board: json["board"],
        title: json["title"],
        wsBoard: json["ws_board"],
        perPage: json["per_page"],
        pages: json["pages"],
        maxFilesize: json["max_filesize"],
        maxWebmFilesize: json["max_webm_filesize"],
        maxCommentChars: json["max_comment_chars"],
        maxWebmDuration: json["max_webm_duration"],
        bumpLimit: json["bump_limit"],
        imageLimit: json["image_limit"],
        cooldowns: Cooldowns.fromJson(json["cooldowns"]),
        metaDescription: json["meta_description"],
        isArchived: json["is_archived"] == null ? null : json["is_archived"],
        spoilers: json["spoilers"] == null ? null : json["spoilers"],
        customSpoilers:
            json["custom_spoilers"] == null ? null : json["custom_spoilers"],
        forcedAnon: json["forced_anon"] == null ? null : json["forced_anon"],
        userIds: json["user_ids"] == null ? null : json["user_ids"],
        countryFlags:
            json["country_flags"] == null ? null : json["country_flags"],
        codeTags: json["code_tags"] == null ? null : json["code_tags"],
        webmAudio: json["webm_audio"] == null ? null : json["webm_audio"],
        minImageWidth:
            json["min_image_width"] == null ? null : json["min_image_width"],
        minImageHeight:
            json["min_image_height"] == null ? null : json["min_image_height"],
        oekaki: json["oekaki"] == null ? null : json["oekaki"],
        sjisTags: json["sjis_tags"] == null ? null : json["sjis_tags"],
        boardFlags: json["board_flags"] == null
            ? null
            : Map.from(json["board_flags"])
                .map((k, v) => MapEntry<String, String>(k, v)),
        textOnly: json["text_only"] == null ? null : json["text_only"],
        requireSubject:
            json["require_subject"] == null ? null : json["require_subject"],
        mathTags: json["math_tags"] == null ? null : json["math_tags"],
      );

  Map<String, dynamic> toJson() => {
        "board": board,
        "title": title,
        "ws_board": wsBoard,
        "per_page": perPage,
        "pages": pages,
        "max_filesize": maxFilesize,
        "max_webm_filesize": maxWebmFilesize,
        "max_comment_chars": maxCommentChars,
        "max_webm_duration": maxWebmDuration,
        "bump_limit": bumpLimit,
        "image_limit": imageLimit,
        "cooldowns": cooldowns.toJson(),
        "meta_description": metaDescription,
        "is_archived": isArchived == null ? null : isArchived,
        "spoilers": spoilers == null ? null : spoilers,
        "custom_spoilers": customSpoilers == null ? null : customSpoilers,
        "forced_anon": forcedAnon == null ? null : forcedAnon,
        "user_ids": userIds == null ? null : userIds,
        "country_flags": countryFlags == null ? null : countryFlags,
        "code_tags": codeTags == null ? null : codeTags,
        "webm_audio": webmAudio == null ? null : webmAudio,
        "min_image_width": minImageWidth == null ? null : minImageWidth,
        "min_image_height": minImageHeight == null ? null : minImageHeight,
        "oekaki": oekaki == null ? null : oekaki,
        "sjis_tags": sjisTags == null ? null : sjisTags,
        "board_flags": boardFlags == null
            ? null
            : Map.from(boardFlags)
                .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "text_only": textOnly == null ? null : textOnly,
        "require_subject": requireSubject == null ? null : requireSubject,
        "math_tags": mathTags == null ? null : mathTags,
      };
}

class Cooldowns {
  Cooldowns({
    this.threads,
    this.replies,
    this.images,
  });

  int threads;
  int replies;
  int images;

  factory Cooldowns.fromJson(Map<String, dynamic> json) => Cooldowns(
        threads: json["threads"],
        replies: json["replies"],
        images: json["images"],
      );

  Map<String, dynamic> toJson() => {
        "threads": threads,
        "replies": replies,
        "images": images,
      };
}
