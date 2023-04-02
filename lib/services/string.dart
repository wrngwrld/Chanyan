String cleanTags(String body) {
  return body.replaceAll(RegExp('<[^>]*>', multiLine: true), '');
}

String unescape(String body) {
  return body
      .replaceAll('&gt;', '>')
      .replaceAll('&lt;', '<')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#47;', '/')
      .replaceAll('&#92;', r'\\')
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&copy;', '©');
}
