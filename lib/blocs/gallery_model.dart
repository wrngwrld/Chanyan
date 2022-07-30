import 'package:flutter/cupertino.dart';

class GalleryProvider with ChangeNotifier {
  GalleryProvider();

  int currentPage = 0;
  String currentMedia = '';

  int getCurrentPage() => currentPage;
  String getCurrentMedia() => currentMedia;

  Future<void> setCurrentPage(int page) async {
    currentPage = page;

    notifyListeners();
  }

  Future<void> setCurrentMedia(String media) async {
    currentMedia = media.split('.')[0];

    notifyListeners();
  }
}
