import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedModel {
  final String userName;
  final List<String> imageUrls;
  final String textContent;

  FeedModel({this.userName, this.textContent, this.imageUrls});

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      userName: json['author'],
      imageUrls: json['url'],
      textContent: json['textContent'],
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
  int voted = 0;

  GestureDetector buildLikeableImage() {
    return new GestureDetector(
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          widget.feedModel.imageUrls.length == 0
              ? SizedBox(height: 0)
              : Stack(
                  children: <Widget>[
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.feedModel.imageUrls.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new CachedNetworkImage(
                            placeholder: (context, url) => Container(
                                  height: 20,
                                  child: new CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.grey),
                                  ),
                                ),
                            imageUrl: widget.feedModel.imageUrls[index],
                            fit: BoxFit.fitWidth,
                          );
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 10,
                        right: 10,
                        child: widget.feedModel.imageUrls.length == 1
                            ? SizedBox()
                            : Icon(
                                Icons.filter,
                                color: Colors.white,
                              ))
                  ],
                )
        ],
      ),
    );
  }

  ListTile buildFeedHeader() {
    return new ListTile(
      leading: widget.feedModel.imageUrls.length != 0
          ? CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.feedModel.imageUrls[0]),
              backgroundColor: Colors.grey,
            )
          : new CircleAvatar(
              backgroundImage: ExactAssetImage("images/anonym.png"),
              backgroundColor: Colors.grey,
            ),
      title: Text("Maraschka"),
      subtitle: Text(
        "Unter Titel Maraschki",
        style: TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(Icons.more_horiz),
      ),
    );
  }

  Widget buildTextContent() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Text(
          widget.feedModel.textContent ?? "",
          textAlign: TextAlign.start,
        ));
  }

  ListTile buildFeedFooter() {
    return new ListTile(
      leading: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    voted = 1;
                  });
                },
                icon: Icon(
                  CupertinoIcons.up_arrow,
                  color: voted != 1 ? Colors.grey : Colors.blue,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 5,
                child: Text(
                  "12",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          Stack(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    voted = -1;
                  });
                },
                icon: Icon(
                  CupertinoIcons.down_arrow,
                  color: voted != -1 ? Colors.grey : Colors.blue,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 5,
                child: Text(
                  "1",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
          //   Stack(
          //               children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                voted = -1;
              });
            },
            icon: Icon(
              CupertinoIcons.conversation_bubble,
              size: 35,
            ),
          ),
          //       Positioned(
          //  left: 15,
          //  top:20,
          //         child: Text("345", style: TextStyle(fontSize: 10,color: Colors.grey),))
          //     ],
          //   ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        buildFeedHeader(),
        buildLikeableImage(),
        widget.feedModel.textContent != null ? buildTextContent() : SizedBox(),
        buildFeedFooter()
      ]),
    );
  }
}
