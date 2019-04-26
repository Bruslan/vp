import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'feed_page.dart';

class TabbarPage extends StatefulWidget {
  const TabbarPage({Key key}) : super(key: key);

  @override
  _TabbarPageState createState() => _TabbarPageState();
}

class _TabbarPageState extends State<TabbarPage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.conversation_bubble),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 2);
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (BuildContext context) {
                return Container(
                  child: FeedPage(),
                );
              },
            );
            break;
          case 1:
            return CupertinoTabView(
              builder: (BuildContext context) => Container(
                    child: FeedPage(),
                  ),
            );
            break;
          case 2:
            return CupertinoTabView(
              builder: (BuildContext context) => Container(),
            );
            break;
        }
        return null;
      },
    );
  }
}
