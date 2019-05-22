import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vp/profile_page.dart';
import 'package:vp/user_model.dart';
import 'database_logic.dart';
import 'cupertione_actionsheet.dart';

class FeedModel {
  final String userName;
  final List<dynamic> imageUrls;
  final String textContent;
  final String userId;
  final String tag;
  final String location;
  final String postId;
  final String timestamp;
  final List<dynamic> options;

  FeedModel(
      {this.options,
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
        postId: json["postId"],
        location: json["location"],
        tag: json["tag"],
        userName: json['userName'],
        imageUrls: json['imageUrls'] == null ? [] : json['imageUrls'],
        textContent: json['textContent'],
        userId: json['userId'],
        options: json["options"] == null ? [] : json["options"],
        timestamp: json["timestamp"]);
  }

  factory FeedModel.fromDocument(DocumentSnapshot doc) {
    return FeedModel.fromJson(doc.data);
  }

  Map<String, Object> toJson() {
    return {
      'userName': userName,
      'imageUrls': imageUrls,
      'textContent': textContent,
      "userId": userId,
      "tag": tag,
      "location": location,
      "postId": postId,
      "timestamp": timestamp,
      "options": options
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
  int voted = 0;
  final FeedCallback onDeleted;

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
        onTap: () =>
            removeDocument("feeds", widget.feedModel.postId).then((onValue) {
              onDeleted();
              Navigator.pop(context);
            }),
      );
    } else {
      return new ListTile(
          leading: new Icon(Icons.delete),
          title: new Text('Melden'),
          onTap: () => reportFeed(
                      "reports", widget.feedModel.postId, widget.currentUserID)
                  .then((onValue) {
                Navigator.pop(context);
              }));
    }
  }

  Widget buildDeleteOrReportCupertino() {
    if (widget.currentUserID == widget.feedModel.userId) {
      return new CupertinoActionSheetAction(
        child: const Text('Delete'),
        onPressed: () =>
            removeDocument("feeds", widget.feedModel.postId).then((onValue) {
              onDeleted();
              Navigator.of(context, rootNavigator: true).pop("Eintrag wurde gelöscht");
            }),
      );
    } else {
      return new CupertinoActionSheetAction(
          child: const Text('Melden'),
          onPressed: () => reportFeed(
                      "reports", widget.feedModel.postId, widget.currentUserID)
                  .then((onValue) {
                Navigator.of(context, rootNavigator: true).pop("Danke für das Melde");
              }));
    }
  }



  int _radioValue = -1;
  bool _showOptionPercentage = false;

  void _handleRadioValueChange(int value) {
    setState(() {

      _radioValue = value;
      _showOptionPercentage = true;

      print(_radioValue);
    });
  }

  Widget _calculateOptionPercentage(int index){

    final testMap = [90,10,80,22];
    
    return Text(testMap[index].toString() +"%");
  }

  _buildOptions() {
    return Container(
      height: widget.feedModel.options.length.toDouble() * 50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.feedModel.options.length,
        itemBuilder: (BuildContext context, int index) {
          return FlatButton(
            onPressed: () {
              _handleRadioValueChange(index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Radio(
                      groupValue: _radioValue,
                      onChanged: _handleRadioValueChange,
                      value: index,
                    ),
                    Text(widget.feedModel.options[index].keys.single.toString()),
                    
                  ],
                ),
                _showOptionPercentage ? _calculateOptionPercentage(index) : SizedBox()
              ],
            ),
          );
        },
      ),
    );
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
          
          containerForSheet<String>(
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
                      Navigator.of(context, rootNavigator: true).pop("Discard");
                    },
                  ))
              );
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
        buildFeedHeader(),
        buildLikeableImage(),
        widget.feedModel.textContent != null ? buildTextContent() : SizedBox(),
        _buildOptions(),
      ]),
    );
  }
}
