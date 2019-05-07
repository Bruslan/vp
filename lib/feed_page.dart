import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_feed_modal.dart';
import 'feeds_list.dart';

class FeedPage extends StatefulWidget {
  final FirebaseUser currentFirebaseUser;

  const FeedPage({Key key, this.currentFirebaseUser}) : super(key: key);
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        trailing: IconButton(
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => CreateFeedModal()));
          },
          icon: Icon(CupertinoIcons.create),
        ),
        middle: Text("Feeds"),
      ),
      body: FeedsList(
        currentUser: widget.currentFirebaseUser
      ),
    );
  }
}
