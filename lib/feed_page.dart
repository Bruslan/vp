import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_feed_modal.dart';
import 'feeds_list.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          trailing: IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => CreateFeedModal(),
              ));
            },
            icon: Icon(CupertinoIcons.create),
          ),
          middle: Text("clean it"),
        ),
        body: FeedsList());
  }
}
