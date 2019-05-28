import 'dart:async';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/auth_class.dart';
import 'package:vp/models/chat_message_model.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/models/user_model.dart';
import 'package:vp/chat_bubble.dart';
// final analytics = new FirebaseAnalytics();

var currentUserEmail;

class ChatPage extends StatefulWidget {
  final String targetUserID;

  const ChatPage({Key key, this.targetUserID}) : super(key: key);
  @override
  ChatPageState createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  String groupID;
  String currentUserID;
  User receiverUserModel;
  User currentUserModel;
  bool ready = false;
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;
  final ScrollController listScrollController = new ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConversationID();
  }

  getConversationID() async {
    FirebaseUser currentFirebaseUser = await Auth().getCurrentUser();

    currentUserID = currentFirebaseUser.uid;

    if (currentFirebaseUser.uid.hashCode <= widget.targetUserID.hashCode) {
      groupID = '${currentFirebaseUser.uid}-${widget.targetUserID}';
    } else {
      groupID = '${widget.targetUserID}-${currentFirebaseUser.uid}';
    }
    currentUserModel = await getUserProfile(currentUserID);
    receiverUserModel = await getUserProfile(widget.targetUserID);
    ready = true;

    setState(() {});
  }

  Widget _buildChatStream() {
    return StreamBuilder(
      stream: getChatStream(groupID),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(212, 20, 15, 1.0),
              ),
            ),
          );
        } else {
          return new ListView.builder(
              reverse: true,
              controller: listScrollController,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                ChatMessage chatMessage =
                    ChatMessage.fromDocument(snapshot.data.documents[index]);

                return Bubble(
                  time: DateTime.parse(chatMessage.timestamp).hour.toString(),
                  message: chatMessage.message,
                  delivered: true,
                  isMe: chatMessage.ownerId != currentUserID,
                );
              });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: CupertinoNavigationBar(
            middle: Text(receiverUserModel != null
                ? receiverUserModel.userName
                : "Loading..")),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                  child: groupID != null ? _buildChatStream() : Container()),
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

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage && ready
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

  void _sendMessage({String messageText, String imageUrl}) async {
    ChatMessage chatMessage = new ChatMessage(
      ownerId: currentUserID,
      message: messageText,
      timestamp: DateTime.now().toString(),
    );

    saveTextChat(chatMessage, groupID).then((onValue) {
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      saveConversation(widget.targetUserID, messageText, currentUserID, groupID,
          currentUserModel, receiverUserModel);
      // analytics.logEvent(name: 'send_message');
    });
  }
}
