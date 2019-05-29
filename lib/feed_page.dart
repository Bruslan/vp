import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/create_feed_modal.dart';
import 'package:vp/feeds_list.dart';


class FeedPage extends StatefulWidget {
  final FirebaseUser currentFirebaseUser;

  const FeedPage({Key key, this.currentFirebaseUser}) : super(key: key);
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: CupertinoNavigationBar(
        trailing: IconButton(
          onPressed: () {
            // BuildContext newContext = context;
            Navigator.of(context, rootNavigator: true)
                .push(CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => CreateFeedModal(
                          oldContext: _context,
                        )));
          },
          icon: Icon(CupertinoIcons.create),
        ),
        middle: Text("Feeds"),
      ),
      body: FeedsList(currentUser: widget.currentFirebaseUser),
    );
  }
}
