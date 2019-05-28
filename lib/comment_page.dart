import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/models/comment_model.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/profile_page.dart';
import 'package:vp/models/user_model.dart';

class CommentsPage extends StatefulWidget {
  final String feedId;
  final String currentUserId;
  CommentsPage({Key key, this.feedId, this.currentUserId}) : super(key: key);

  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool _isComposingMessage = false;
  List<CommentModel> commentsList = new List();
  final TextEditingController _textEditingController =
      new TextEditingController();

  _collectCommentsForFeed() async {
    List<CommentModel> comments = (await getCommentsForFeed(widget.feedId));
    commentsList = comments;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _collectCommentsForFeed();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: CupertinoNavigationBar(middle: Text("Comments")),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(child: _buildListView()),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: SafeArea(child: _buildTextComposer()),
              ),
              new Builder(builder: (BuildContext context) {
                return new Container(width: 0.0, height: 0.0);
              })
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(
                  color: Colors.grey[200],
                )))
              : null,
        ));
  }

  _buildProfileImage(int index) {
    if (commentsList[index].imageProfileUrl != null) {
      return CircleAvatar(
        backgroundImage:
            CachedNetworkImageProvider(commentsList[index].imageProfileUrl),
        backgroundColor: Colors.grey,
      );
    } else {
      return new CircleAvatar(
        backgroundImage: ExactAssetImage("images/anonym.png"),
        backgroundColor: Colors.grey,
      );
    }
  }

  _buildListView() {
    return ListView.builder(
      itemCount: commentsList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => ProfilePage(
                            currentUser: false,
                            targetUserId: commentsList[index].userId,
                          )));
            },
            child: _buildProfileImage(index),
          ),
          title: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => ProfilePage(
                              currentUser: false,
                              targetUserId: commentsList[index].userId,
                            )));
              },
              child: Text(commentsList[index].userName)),
          subtitle: Text(commentsList[index].textContent),
        );
      },
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {}),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textEditingController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _textMessageSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });
    _sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String messageText, String imageUrl}) async {
    print("------");

    User currentUser = await getUserProfile(widget.currentUserId);

    CommentModel comment = new CommentModel(
      imageUrl: imageUrl,
      userId: widget.currentUserId,
      userName: currentUser.userName,
      imageProfileUrl: currentUser.profileImageUrl,
      textContent: messageText,
      timestamp: (DateTime.now().toString()),
    );
    createCommentForFeed(widget.feedId, comment).then((_) {
      commentsList.clear();

      _collectCommentsForFeed();
    });
  }
}
