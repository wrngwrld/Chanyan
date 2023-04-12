class SavedAttachment {
  SavedAttachment({
    this.savedAttachmentType,
    this.fileName,
    this.thumbnail,
  });

  factory SavedAttachment.fromJson(Map<String, dynamic> json) {
    return SavedAttachment(
      savedAttachmentType: json['savedAttachmentType'] as String?,
      fileName: json['fileName'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  String? savedAttachmentType;
  String? fileName;
  String? thumbnail;

  Map<String, dynamic> toJson() {
    return {
      'savedAttachmentType': savedAttachmentType,
      'fileName': fileName,
      'thumbnail': thumbnail,
    };
  }
}
