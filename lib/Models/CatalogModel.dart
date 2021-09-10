// To parse this JSON data, do
//
//     final catalogModel = catalogModelFromJson(jsonString);

import 'dart:convert';

List<CatalogModel> catalogModelFromJson(String str) => List<CatalogModel>.from(
    json.decode(str).map((x) => CatalogModel.fromJson(x)));

String catalogModelToJson(List<CatalogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatalogModel {
  CatalogModel({
    this.page,
    this.threads,
  });

  int page;
  List<ThreadCatalogModel> threads;

  factory CatalogModel.fromJson(Map<String, dynamic> json) => CatalogModel(
        page: json["page"],
        threads: List<ThreadCatalogModel>.from(
            json["threads"].map((x) => ThreadCatalogModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "threads": List<dynamic>.from(threads.map((x) => x.toJson())),
      };
}

class ThreadCatalogModel {
  ThreadCatalogModel({
    this.no,
    this.sticky,
    this.closed,
    this.now,
    this.name,
    this.sub,
    this.com,
    this.filename,
    this.ext,
    this.w,
    this.h,
    this.tnW,
    this.tnH,
    this.tim,
    this.time,
    this.md5,
    this.fsize,
    this.resto,
    this.capcode,
    this.semanticUrl,
    this.replies,
    this.images,
    this.lastReplies,
    this.lastModified,
    this.bumplimit,
    this.imagelimit,
    this.omittedPosts,
    this.omittedImages,
    this.trip,
  });

  int no;
  int sticky;
  int closed;
  String now;
  ThreadName name;
  String sub;
  String com;
  String filename;
  Ext ext;
  int w;
  int h;
  int tnW;
  int tnH;
  int tim;
  int time;
  String md5;
  int fsize;
  int resto;
  String capcode;
  String semanticUrl;
  int replies;
  int images;
  List<LastReply> lastReplies;
  int lastModified;
  int bumplimit;
  int imagelimit;
  int omittedPosts;
  int omittedImages;
  String trip;

  factory ThreadCatalogModel.fromJson(Map<String, dynamic> json) =>
      ThreadCatalogModel(
        no: json["no"],
        sticky: json["sticky"] == null ? null : json["sticky"],
        closed: json["closed"] == null ? null : json["closed"],
        now: json["now"],
        name: threadNameValues.map[json["name"]],
        sub: json["sub"] == null ? null : json["sub"],
        com: json["com"] == null ? null : json["com"],
        filename: json["filename"],
        ext: extValues.map[json["ext"]],
        w: json["w"],
        h: json["h"],
        tnW: json["tn_w"],
        tnH: json["tn_h"],
        tim: json["tim"],
        time: json["time"],
        md5: json["md5"],
        fsize: json["fsize"],
        resto: json["resto"],
        capcode: json["capcode"] == null ? null : json["capcode"],
        semanticUrl: json["semantic_url"],
        replies: json["replies"],
        images: json["images"],
        lastReplies: json["last_replies"] == null
            ? null
            : List<LastReply>.from(
                json["last_replies"].map((x) => LastReply.fromJson(x))),
        lastModified: json["last_modified"],
        bumplimit: json["bumplimit"] == null ? null : json["bumplimit"],
        imagelimit: json["imagelimit"] == null ? null : json["imagelimit"],
        omittedPosts:
            json["omitted_posts"] == null ? null : json["omitted_posts"],
        omittedImages:
            json["omitted_images"] == null ? null : json["omitted_images"],
        trip: json["trip"] == null ? null : json["trip"],
      );

  Map<String, dynamic> toJson() => {
        "no": no,
        "sticky": sticky == null ? null : sticky,
        "closed": closed == null ? null : closed,
        "now": now,
        "name": threadNameValues.reverse[name],
        "sub": sub == null ? null : sub,
        "com": com == null ? null : com,
        "filename": filename,
        "ext": extValues.reverse[ext],
        "w": w,
        "h": h,
        "tn_w": tnW,
        "tn_h": tnH,
        "tim": tim,
        "time": time,
        "md5": md5,
        "fsize": fsize,
        "resto": resto,
        "capcode": capcode == null ? null : capcode,
        "semantic_url": semanticUrl,
        "replies": replies,
        "images": images,
        "last_replies": lastReplies == null
            ? null
            : List<dynamic>.from(lastReplies.map((x) => x.toJson())),
        "last_modified": lastModified,
        "bumplimit": bumplimit == null ? null : bumplimit,
        "imagelimit": imagelimit == null ? null : imagelimit,
        "omitted_posts": omittedPosts == null ? null : omittedPosts,
        "omitted_images": omittedImages == null ? null : omittedImages,
        "trip": trip == null ? null : trip,
      };
}

enum Ext { GIF, WEBM }

final extValues = EnumValues({".gif": Ext.GIF, ".webm": Ext.WEBM});

class LastReply {
  LastReply({
    this.no,
    this.now,
    this.name,
    this.com,
    this.time,
    this.resto,
    this.capcode,
    this.filename,
    this.ext,
    this.w,
    this.h,
    this.tnW,
    this.tnH,
    this.tim,
    this.md5,
    this.fsize,
    this.since4Pass,
    this.trip,
  });

  int no;
  String now;
  LastReplyName name;
  String com;
  int time;
  int resto;
  String capcode;
  String filename;
  Ext ext;
  int w;
  int h;
  int tnW;
  int tnH;
  int tim;
  String md5;
  int fsize;
  int since4Pass;
  String trip;

  factory LastReply.fromJson(Map<String, dynamic> json) => LastReply(
        no: json["no"],
        now: json["now"],
        name: lastReplyNameValues.map[json["name"]],
        com: json["com"] == null ? null : json["com"],
        time: json["time"],
        resto: json["resto"],
        capcode: json["capcode"] == null ? null : json["capcode"],
        filename: json["filename"] == null ? null : json["filename"],
        ext: json["ext"] == null ? null : extValues.map[json["ext"]],
        w: json["w"] == null ? null : json["w"],
        h: json["h"] == null ? null : json["h"],
        tnW: json["tn_w"] == null ? null : json["tn_w"],
        tnH: json["tn_h"] == null ? null : json["tn_h"],
        tim: json["tim"] == null ? null : json["tim"],
        md5: json["md5"] == null ? null : json["md5"],
        fsize: json["fsize"] == null ? null : json["fsize"],
        since4Pass: json["since4pass"] == null ? null : json["since4pass"],
        trip: json["trip"] == null ? null : json["trip"],
      );

  Map<String, dynamic> toJson() => {
        "no": no,
        "now": now,
        "name": lastReplyNameValues.reverse[name],
        "com": com == null ? null : com,
        "time": time,
        "resto": resto,
        "capcode": capcode == null ? null : capcode,
        "filename": filename == null ? null : filename,
        "ext": ext == null ? null : extValues.reverse[ext],
        "w": w == null ? null : w,
        "h": h == null ? null : h,
        "tn_w": tnW == null ? null : tnW,
        "tn_h": tnH == null ? null : tnH,
        "tim": tim == null ? null : tim,
        "md5": md5 == null ? null : md5,
        "fsize": fsize == null ? null : fsize,
        "since4pass": since4Pass == null ? null : since4Pass,
        "trip": trip == null ? null : trip,
      };
}

enum LastReplyName {
  ANONYMOUS,
  SHALOM_FELLOW_WHITE_WOMEN,
  BIG_HERP,
  SAGE,
  KING_CUM,
  NAME_SAGE,
  HADES,
  DEP_FA,
  ANALISASWALLOW_YAHOO,
  MWAH
}

final lastReplyNameValues = EnumValues({
  "Analisaswallow@yahoo": LastReplyName.ANALISASWALLOW_YAHOO,
  "Anonymous": LastReplyName.ANONYMOUS,
  "Big Herp": LastReplyName.BIG_HERP,
  "DepFA": LastReplyName.DEP_FA,
  "Hades": LastReplyName.HADES,
  "King-Cum": LastReplyName.KING_CUM,
  "Mwah": LastReplyName.MWAH,
  "Sage": LastReplyName.NAME_SAGE,
  "SAGE": LastReplyName.SAGE,
  "shalom fellow white women": LastReplyName.SHALOM_FELLOW_WHITE_WOMEN
});

enum ThreadName {
  ANONYMOUS,
  ARGENTINIAN_SISSY,
  DIRTY_TALK,
  ASIAN_GIRL_ENJOYER,
  JAPANESE_TRAIN_FLASHING,
  THE_4_CHANGAYAF,
  KING_CUM,
  EMERGENCY_DUMP_MAN,
  NIKKI,
  DEP_FA,
  ANON
}

final threadNameValues = EnumValues({
  "anon": ThreadName.ANON,
  "Anonymous": ThreadName.ANONYMOUS,
  "ArgentinianSissy": ThreadName.ARGENTINIAN_SISSY,
  "Asian Girl Enjoyer": ThreadName.ASIAN_GIRL_ENJOYER,
  "DepFA": ThreadName.DEP_FA,
  "Dirty talk": ThreadName.DIRTY_TALK,
  "Emergency Dump Man": ThreadName.EMERGENCY_DUMP_MAN,
  "Japanese train flashing": ThreadName.JAPANESE_TRAIN_FLASHING,
  "King-Cum": ThreadName.KING_CUM,
  "Nikki": ThreadName.NIKKI,
  "4changayaf": ThreadName.THE_4_CHANGAYAF
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
