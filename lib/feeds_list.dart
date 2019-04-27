import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'feed_model.dart';

class FeedsList extends StatefulWidget {
  FeedsList({Key key}) : super(key: key);

  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  List<FeedModel> feedModelList = [
    FeedModel(imageUrls: [], textContent: "The web has been transitioning from “static sites” (where a content is pushed from the owner to reader) and into digital experiences that foster community interaction and contribution. activity feeds are the entry point if you’re looking to have a “lite” community aspect in your user experience. activity feeds can provide offline and online conversation points between a team (think basecamp or people discussing a facebook post)."),
    FeedModel(imageUrls: ["https://cdn.pixabay.com/photo/2017/10/25/16/54/african-lion-2888519_1280.jpg", "https://cdn.pixabay.com/photo/2014/12/12/19/45/lion-565820_1280.jpg"]),
    FeedModel(textContent: "Feeds are fun! It’s really one of the best UI patterns to share and promote content between users. Through a few different perspectives, we’ll break down the activity Feed UI Pattern. You'll see just how many different and diverse ways there are to design an activity feed.", imageUrls: ["https://cdn.pixabay.com/photo/2014/11/03/11/07/lion-515028_1280.jpg"]),
    FeedModel( imageUrls: ["https://cdn.pixabay.com/photo/2014/12/12/19/45/lion-565820_1280.jpg"]),
    FeedModel(imageUrls: ["https://cdn.pixabay.com/photo/2015/11/16/16/28/bird-1045954_1280.jpg"])
  ];

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
        ), onRefresh: () {
        },
      ),
    );
  }
}



