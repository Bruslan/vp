import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/auth_class.dart';

import 'feed_page.dart';
import 'conversations_page.dart';
import 'profile_page.dart';

class TabbarPage extends StatefulWidget {
  final FirebaseUser firebaseUser;
  const TabbarPage(
      {Key key, String userId, BaseAuth auth, onSignedOut, this.firebaseUser})
      : super(key: key);

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
            icon: Stack(
              children: <Widget>[
                Icon(CupertinoIcons.conversation_bubble),
                new Positioned(
                  // draw a red marble
                  top: 0.0,
                  right: 0.0,
                  child: new Icon(Icons.brightness_1,
                      size: 8.0, color: Colors.redAccent),
                )
              ],
            ),
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
                  child: FeedPage(currentFirebaseUser: widget.firebaseUser),
                );
              },
            );
            break;
          case 1:
            return CupertinoTabView(
              builder: (BuildContext context) => Container(
                    child: ConversationPage(
                        currentUserID: widget.firebaseUser.uid),
                  ),
            );
            break;
          case 2:
            return CupertinoTabView(
              builder: (BuildContext context) => ProfilePage(
                    currentUser: true,
                    targetUserId: widget.firebaseUser.uid,
                  ),
            );
            break;
        }
        return null;
      },
    );
  }
}
