import 'dart:async';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import 'dart:math';
// final analytics = new FirebaseAnalytics();

var currentUserEmail;
var _scaffoldContext;

class ChatPage extends StatefulWidget {
  final String currentUser;
  final String conversationId;
  final String receiverID;
  final String receiverUserName;

  const ChatPage(
      {Key key,
      this.currentUser,
      this.conversationId,
      this.receiverID,
      this.receiverUserName})
      : super(key: key);
  @override
  ChatPageState createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;

  String groupChatId;
  final ScrollController listScrollController = new ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: CupertinoNavigationBar(

          middle: Text("Chat mit Kakaschki"),
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                // child: StreamBuilder(
                //   stream: Firestore.instance
                //       .collection("messages")
                //       .document(groupChatId)
                //       .collection("messages")
                //       .orderBy('timestamp', descending: true)
                //       .limit(20)
                //       .snapshots(),

                child: new ListView.builder(
                    reverse: true,
                    controller: listScrollController,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      Random random = new Random();
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Bubble(
                          message: "hallo das ist ein Beispiel Chat tesxt",
                          time: "12:02",
                          isMe: random.nextBool(),
                          delivered: true,
                        
                        ),
                      );
                    }),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                _scaffoldContext = context;
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

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });
    _sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String messageText, String imageUrl}) {}
}
