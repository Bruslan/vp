import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedModel {
  final String userName;
  final String imageUrl;

  FeedModel({this.userName, this.imageUrl});

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      userName: json['author'],
      imageUrl: json['url'],
    );
  }
}

class FeedFromModel extends StatefulWidget {
  final FeedModel feedModel;
  const FeedFromModel({Key key, @required this.feedModel}) : super(key: key);

  @override
  _FeedFromModelState createState() => _FeedFromModelState();
}

class _FeedFromModelState extends State<FeedFromModel> {
  GestureDetector buildLikeableImage() {
    return new GestureDetector(
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          widget.feedModel.imageUrl == ""
              ? SizedBox(height: 0)
              : new CachedNetworkImage(
                  placeholder: (context, url) => new CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                  imageUrl: widget.feedModel.imageUrl,
                  fit: BoxFit.fitWidth,
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        buildLikeableImage(),
      ]),
    );
  }
}
