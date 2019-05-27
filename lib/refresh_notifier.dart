import 'package:flutter/material.dart';

class RefreshNotifier extends ChangeNotifier {
  bool _refresh = false;
  bool get refresh => _refresh;

  set refresh(bool val) {
    _refresh = val;
    print(val);
    notifyListeners();
  }

  hasRefreshed() {
    refresh = false;
  }

  mustRefresh() {
    refresh = true;
  }
}
