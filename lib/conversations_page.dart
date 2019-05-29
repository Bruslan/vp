import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/chat_page.dart';

class ConversationPage extends StatelessWidget {
  final String currentUserID;
  const ConversationPage({Key key, this.currentUserID}) : super(key: key);

  _buildConversationListTile(AsyncSnapshot snapshot, int index) {
    return ListTile(
      trailing: Icon(Icons.keyboard_arrow_right),
      title: Text(snapshot.data.documents[index]["username"]),
      subtitle: Text(snapshot.data.documents[index]["lastMessage"]),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: snapshot.data.documents[index]["avatarUrl"] != ""
            ? new NetworkImage(snapshot.data.documents[index]["avatarUrl"])
            : new ExactAssetImage("images/anonym.png"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("Conversations"),
        ),
        body: Container(
            child: StreamBuilder(
          stream: getConversationStream(currentUserID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Slidable(
                        delegate: new SlidableDrawerDelegate(),
                        actionExtentRatio: 0.25,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(
                              builder: (context) => ChatPage(
                                  targetUserID: snapshot.data.documents[index]
                                      ["receiverID"]),
                            ));
                          },
                          child: _buildConversationListTile(snapshot, index),
                        ),
                        secondaryActions: <Widget>[
                          new IconSlideAction(
                              caption: 'More',
                              color: Colors.black45,
                              icon: Icons.more_horiz,
                              onTap: () => {}),
                          new IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => {
                                    removeConversation(
                                        currentUserID,
                                        snapshot.data.documents[index]
                                            ["conversationId"])
                                  }),
                        ],
                      ),
                      Divider()
                    ],
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(212, 20, 15, 1.0),
                  ),
                ),
              );
            }
          },
        )));
  }
}
