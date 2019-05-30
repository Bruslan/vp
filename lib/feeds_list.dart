import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vp/models/feed_model.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/filter_pins.dart';

import 'change_notifiers.dart';

class FeedsList extends StatefulWidget {
  final FirebaseUser currentUser;
  FeedsList({Key key, this.currentUser}) : super(key: key);

  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  BuildContext _context;
  final int getThatMuchFeeds = 10;
  bool mustRefresh = false;
  bool mustLoadMore = false;
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

  ScrollController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);

    _collectFeeds();
  }

  _collectFeeds() async {
    List<FeedModel> feeds =
        (await getFeeds(getThatMuchFeeds, "feeds", tagsMap));
    feedModelList = feeds;
    print(feedModelList.length);
    if (mounted) {
      setState(() {});
    }
  }

  _loadMore() async {
    List<FeedModel> newFeeds = (await loadMoreFeeds(
        feedModelList[feedModelList.length - 1],
        getThatMuchFeeds,
        "feeds",
        tagsMap));
    print(newFeeds.length);
    feedModelList.addAll(newFeeds);
    print(feedModelList.length);
    if (!(newFeeds.length < getThatMuchFeeds)){
 mustLoadMore = false;
    }
   
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    final refresher = Provider.of<FeedRefresh>(context);
    return Column(
      children: <Widget>[
        refresher.refresh ? LinearProgressIndicator() : SizedBox(),
        TagPills(
          onTagsSet: (tags) {
            if (mounted) {
              setState(() {
                tagsMap = tags;
              });
            }

            _collectFeeds();
          },
          tags: tagsMap,
        ),
        Expanded(
          child: RefreshIndicator(
              child: ListView.builder(
                controller: controller,
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

  void _scrollListener() {
    if (controller.position.extentAfter < 400) {
      if (!mustLoadMore) {
        print("have to load more");
        _loadMore();

        if (mounted) {
          setState(() {
            mustLoadMore = true;
          });
        }
      }
    }
  }

  Future<void> _refresh() async {
    feedModelList.clear();
    await _collectFeeds();
  }
}
