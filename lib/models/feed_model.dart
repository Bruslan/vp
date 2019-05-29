import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vp/profile_page.dart';
import 'package:vp/models/user_model.dart';
import 'package:vp/comment_page.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/cupertione_actionsheet.dart';
import 'package:vp/options_model.dart';

import '../voting_system.dart';

class FeedModel {
  final int upVotes;
  final int downVotes;
  final String userName;
  final List<dynamic> imageUrls;
  final String textContent;
  final String userId;
  final String tag;
  final String location;
  final String postId;
  final String timestamp;
  final bool hasOptions;
  final int commentCount;

  FeedModel(
      {this.upVotes,
      this.downVotes,
      this.commentCount,
      this.hasOptions,
      this.userName,
      this.textContent,
      this.imageUrls,
      this.userId,
      this.postId,
      this.location,
      this.tag,
      this.timestamp});

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
        upVotes: json["upVotes"],
        downVotes: json["downVotes"],
        postId: json["postId"],
        commentCount: json["commentCount"],
        location: json["location"],
        tag: json["tag"],
        userName: json['userName'],
        imageUrls: json['imageUrls'] == null ? [] : json['imageUrls'],
        textContent: json['textContent'],
        userId: json['userId'],
        hasOptions: json["hasOptions"],
        timestamp: json["timestamp"]);
  }

  factory FeedModel.fromDocument(DocumentSnapshot doc) {
    return FeedModel.fromJson(doc.data);
  }

  Map<String, Object> toJson() {
    return {
      "upVotes": upVotes,
      "downVotes": downVotes,
      "commentCount": commentCount,
      'userName': userName,
      'imageUrls': imageUrls,
      'textContent': textContent,
      "userId": userId,
      "tag": tag,
      "location": location,
      "postId": postId,
      "timestamp": timestamp,
      "hasOptions": hasOptions
    };
  }
}

typedef FeedCallback = void Function();

class FeedFromModel extends StatefulWidget {
  final String currentUserID;
  final FeedModel feedModel;
  final FeedCallback onDeleted;

  const FeedFromModel(
      {Key key, @required this.feedModel, this.onDeleted, this.currentUserID})
      : super(key: key);

  @override
  _FeedFromModelState createState() => _FeedFromModelState(onDeleted);
}

class _FeedFromModelState extends State<FeedFromModel> {
  final FeedCallback onDeleted;
  User currentUserModel;

  _FeedFromModelState(this.onDeleted);
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
                      height: 350,
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

  Widget buildDeleteOrReport() {
    if (widget.currentUserID == widget.feedModel.userId) {
      return new ListTile(
          leading: new Icon(Icons.delete),
          title: new Text('Löschen'),
          onTap: () {
            removeDocument("feeds", widget.feedModel.postId).then((onValue) {
              onDeleted();

              Navigator.of(context, nullOk: true, rootNavigator: true)
                  .pop(context);
            });
          });
    } else {
      return new ListTile(
          leading: new Icon(Icons.delete),
          title: new Text('Melden'),
          onTap: () => reportFeed(
                      "reports", widget.feedModel.postId, widget.currentUserID)
                  .then((onValue) {
                Navigator.of(context, nullOk: true, rootNavigator: true)
                    .pop(context);
              }));
    }
  }

  openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[buildDeleteOrReport()],
            ),
          );
        });
  }

  Widget buildDeleteOrReportCupertino() {
    if (widget.currentUserID == widget.feedModel.userId) {
      return new CupertinoActionSheetAction(
          child: const Text('Delete'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop("Erfolgreich gelöscht");
            removeDocument("feeds", widget.feedModel.postId).then((onValue) {
              onDeleted();
            });
          });
    } else {
      return new CupertinoActionSheetAction(
          child: const Text('Melden'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop("Danke für das Melde");
            reportFeed(
                "reports", widget.feedModel.postId, widget.currentUserID);
          });
    }
  }

  ListTile buildFeedHeader() {
    return new ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => ProfilePage(
                    currentUser: false,
                    targetUserId: widget.feedModel.userId,
                  )));
        },
        child: new FutureBuilder(
          future: getUserProfile(widget.feedModel.userId),
          builder: (BuildContext context, AsyncSnapshot<User> user) {
            if (user.hasData) {
              if (user.data != null) {
                currentUserModel = user.data;
                if (user.data.profileImageUrl != "") {
                  return CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(user.data.profileImageUrl),
                    backgroundColor: Colors.grey,
                  );
                } else {
                  return new CircleAvatar(
                    backgroundImage: ExactAssetImage("images/anonym.png"),
                    backgroundColor: Colors.grey,
                  );
                }
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      title: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => ProfilePage(
                      currentUser: false,
                      targetUserId: widget.feedModel.userId,
                    )));
          },
          child: Text(widget.feedModel.userName)),
      subtitle: Text(
        "Unter Titel Maraschki",
        style: TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        onPressed: () {
          Platform.isIOS
              ? containerForSheet<String>(
                  context: context,
                  child: CupertinoActionSheet(
                      title: const Text('Was wollen Sie tun?'),
                      // message: const Text('Your options are '),
                      actions: <Widget>[
                        buildDeleteOrReportCupertino(),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: const Text('Cancel'),
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop("Discard");
                        },
                      )))
              : openBottomSheet(context);
        },
        icon: Icon(Icons.more_horiz),
      ),
    );
  }

  Widget buildTextContent() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 5, 10, 0),
        child: Text(
          widget.feedModel.textContent ?? "",
          textAlign: TextAlign.start,
        ));
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) => CommentsPage(
                            currentUserId: widget.currentUserID,
                            feedId: widget.feedModel.postId,
                          )));
            },
            child: widget.feedModel.commentCount == null
                ? Text(
                    "Kommentieren",
                    style: TextStyle(color: Colors.grey),
                  )
                : Row(
                    children: <Widget>[
                      Text(
                        "Alle ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        widget.feedModel.commentCount.toString(),
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        " Kommentare anzeigen",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
        Votes(
          feedId: widget.feedModel.postId,
          upVotes: widget.feedModel.upVotes,
          downVotes: widget.feedModel.downVotes,
          currentUserID: widget.currentUserID,
        ),
      ],
    );
  }

  _buildOptions() {
    return Options(
      feedId: widget.feedModel.postId,
      currentUser: widget.currentUserID,
    );
  }

  User feedUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getUser() async {
    User user = await getUserProfile(widget.feedModel.userId);
    feedUser = user;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildFeedHeader(),
            buildLikeableImage(),
            widget.feedModel.textContent != null
                ? buildTextContent()
                : SizedBox(),
            widget.feedModel.hasOptions ? _buildOptions() : SizedBox(),
            _buildActionButtons(),
          ]),
    );
  }
}
