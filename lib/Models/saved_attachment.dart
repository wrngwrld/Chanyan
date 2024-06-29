enum SavedAttachmentType { Image, Video }

class SavedAttachment {
  SavedAttachment({
    this.savedAttachmentType,
    this.fileName,
    this.thumbnail,
  });

  factory SavedAttachment.fromJson(Map<String, dynamic> json) {
    return SavedAttachment(
      savedAttachmentType:
          SavedAttachmentType.values.byName(json['savedAttachmentType']),
      fileName: json['fileName'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  SavedAttachmentType? savedAttachmentType;
  String? fileName;
  String? thumbnail;

  Map<String, dynamic> toJson() {
    return {
      'savedAttachmentType': savedAttachmentType?.name,
      'fileName': fileName,
      'thumbnail': thumbnail,
    };
  }
}
