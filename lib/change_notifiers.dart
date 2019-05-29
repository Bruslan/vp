import 'package:flutter/widgets.dart';

class FeedRefresh extends ChangeNotifier {
  bool _refreshFeed = false;
  bool loadingBar = false;
  bool get refresh => _refreshFeed;

  set refresh(bool val) {
    _refreshFeed = val;
    notifyListeners();
  }

  mustRefresh() {
    refresh = true;
  }

  hasRefreshed() {
    refresh = false;
  }
}
