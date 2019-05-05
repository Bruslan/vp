import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_feed_modal.dart';
import 'feeds_list.dart';

class FeedPage extends StatefulWidget {
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
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (context) => CreateFeedModal(
                    currentUser: null,
                  ),
            ));
          },
          icon: Icon(CupertinoIcons.create),
        ),
        middle: Text("Feeds"),
      ),
      body: FeedsList(),
    );
  }
}
