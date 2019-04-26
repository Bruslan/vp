import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'feed_model.dart';

class FeedsList extends StatefulWidget {
  FeedsList({Key key}) : super(key: key);

  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  List<FeedModel> feedModelList = [
    FeedModel(imageUrl: "https://cdn.pixabay.com/photo/2017/10/25/16/54/african-lion-2888519_1280.jpg")
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: feedModelList.length,
        itemBuilder: (BuildContext context, int index) {
          return FeedFromModel(
            feedModel: feedModelList[index],
          );
        },
      ), onRefresh: () {
      },
    );
  }
}



