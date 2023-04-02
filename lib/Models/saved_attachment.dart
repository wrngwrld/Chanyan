class SavedAttachment {
  SavedAttachment({
    this.savedAttachmentType,
    this.fileName,
    this.thumbnail,
  });

  factory SavedAttachment.fromJson(Map<String, dynamic> json) {
    return SavedAttachment(
      savedAttachmentType: json['savedAttachmentType'],
      fileName: json['fileName'],
      thumbnail: json['thumbnail'],
    );
  }

  String savedAttachmentType;
  String fileName;
  String thumbnail;

  Map<String, dynamic> toJson() {
    return {
      'savedAttachmentType': savedAttachmentType,
      'fileName': fileName,
      'thumbnail': thumbnail,
    };
  }
}
