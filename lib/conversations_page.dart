import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'chat_page.dart';

class ConversationPage extends StatelessWidget {
  final String currentUserID;
  const ConversationPage({Key key, this.currentUserID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("create"),
        ),
        body: Container(
          child: ListView.builder(
            itemCount: 6,
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
                          builder: (context) => ChatPage(),
                        ));
                      },
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        title: Text("bruslan"),
                        subtitle: Text("Wo bist du biatch :("),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              new NetworkImage('http://i.pravatar.cc/300'),
                        ),
                      ),
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
                          onTap: () => {}),
                    ],
                  ),
                  Divider()
                ],
              );
            },
          ),
        ));
  }
}
