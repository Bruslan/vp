import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_feed_modal.dart';
import 'feeds_list.dart';
import 'filter_pins.dart';

class FeedPage extends StatelessWidget {

    List<Map<String, dynamic>> tagsMap = [
        {
      "name": "Favos",
      "value": false,
    },
    {
      "name": "VayGirls",
      "value": false,
    },
    {"name": "VayBoys", "value": false},
    {"name": "VayMusic", "value": false},
    {"name": "VayShop", "value": false},
    {"name": "VayBöhum", "value": false},
  ];

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
          middle: Text("Feed"),
        ),
        body: Column(
          children: <Widget>[
            TagPills(
              tags: tagsMap,
            ),
            FeedsList(),
          ],
        ));
  }
}
