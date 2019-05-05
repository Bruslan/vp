import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'feed_model.dart';
import 'database_logic.dart';

class FeedsList extends StatefulWidget {
  final List<Map<String, dynamic>> tagsMap;
  FeedsList({Key key, this.tagsMap}) : super(key: key);

  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  List<FeedModel> feedModelList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _collectFeeds();
  }

  _collectFeeds() async {
    List<FeedModel> feeds = (await getFeeds(10, "feeds", widget.tagsMap));
    feedModelList = feeds;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        child: ListView.builder(
          itemCount: feedModelList.length,
          itemBuilder: (BuildContext context, int index) {
            return FeedFromModel(
              feedModel: feedModelList[index],
            );
          },
        ),
        onRefresh: () {},
      ),
    );
  }
}
