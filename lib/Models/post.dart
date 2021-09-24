class Post {
  Post({
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
    this.uniqueIps,
    this.lastModified,
    this.country,
    this.board,
    this.archived,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        no: json['no'],
        sticky: json['sticky'],
        closed: json['closed'],
        now: json['now'],
        name: json['name'],
        sub: json['sub'],
        com: json['com'],
        filename: json['filename'],
        ext: json['ext'],
        w: json['w'],
        h: json['h'],
        tnW: json['tn_w'],
        tnH: json['tn_h'],
        tim: json['tim'],
        time: json['time'],
        md5: json['md5'],
        fsize: json['fsize'],
        resto: json['resto'],
        capcode: json['capcode'],
        semanticUrl: json['semantic_url'],
        replies: json['replies'],
        images: json['images'],
        uniqueIps: json['unique_ips'],
        lastModified: json['last_modified'],
        country: json['country'],
        board: json['board'],
        archived: json['archived'],
      );

  int no;
  int sticky;
  int closed;
  String now;
  String name;
  String sub;
  String com;
  String filename;
  String ext;
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
  int uniqueIps;
  int lastModified;
  String country;
  String board;
  int archived;

  Map<String, dynamic> toJson() => {
        'no': no,
        'sticky': sticky,
        'closed': closed,
        'now': now,
        'name': name,
        'sub': sub,
        'com': com,
        'filename': filename,
        'ext': ext,
        'w': w,
        'h': h,
        'tn_w': tnW,
        'tn_h': tnH,
        'tim': tim,
        'time': time,
        'md5': md5,
        'fsize': fsize,
        'resto': resto,
        'capcode': capcode,
        'semantic_url': semanticUrl,
        'replies': replies,
        'images': images,
        'unique_ips': uniqueIps,
        'board': board,
        'archived': archived,
      };
}
