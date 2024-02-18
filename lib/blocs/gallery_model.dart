import 'package:flutter/cupertino.dart';

class GalleryProvider with ChangeNotifier {
  GalleryProvider();

  int currentPage = 0;
  String currentMedia = '';
  bool _controlsVisible = true;

  int getCurrentPage() => currentPage;
  String getCurrentMedia() => currentMedia;
  bool getControlsVisible() => _controlsVisible;

  Future<void> setCurrentPage(int page) async {
    currentPage = page;

    notifyListeners();
  }

  Future<void> setCurrentMedia(String media) async {
    currentMedia = media.split('.')[0];

    notifyListeners();
  }

  Future<void> setControlsVisible(bool visible) async {
    _controlsVisible = visible;

    notifyListeners();
  }
}
