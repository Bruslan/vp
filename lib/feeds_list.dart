import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vp/refresh_notifier.dart';
import 'package:vp/models/feed_model.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/filter_pins.dart';

class FeedsList extends StatefulWidget {
  final FirebaseUser currentUser;
  FeedsList({Key key, this.currentUser}) : super(key: key);

  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  BuildContext _context;
  bool mustRefresh = false;
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

  List<FeedModel> feedModelList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _collectFeeds();
  }

  _collectFeeds() async {
    List<FeedModel> feeds = (await getFeeds(10, "feeds", tagsMap));
    feedModelList = feeds;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    final refreshNotifier = Provider.of<RefreshNotifier>(context);
    setState(() {
      mustRefresh = refreshNotifier.refresh;
    });

    return Column(
      children: <Widget>[
        TagPills(
          onTagsSet: (tags) {
            setState(() {
              tagsMap = tags;
            });
            _collectFeeds();
          },
          tags: tagsMap,
        ),
        Expanded(
          child: RefreshIndicator(
              child: ListView.builder(
                itemCount: feedModelList.length,
                itemBuilder: (BuildContext context, int index) {
                  return FeedFromModel(
                      currentUserID: widget.currentUser.uid,
                      feedModel: feedModelList[index],
                      onDeleted: _refresh);
                },
              ),
              onRefresh: _refresh),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    feedModelList.clear();
    await _collectFeeds();
  }
}
