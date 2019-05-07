import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/user_model.dart';
import 'auth_class.dart';

class ProfilePage extends StatelessWidget {
  final String targetUserId;
  const ProfilePage({Key key, this.targetUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          expandedHeight: 250.0,
          // pinned: true,
          flexibleSpace: new FlexibleSpaceBar(
            background: Stack(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder(
                      future: getUserProfile(targetUserId),
                      builder:
                          (BuildContext context, AsyncSnapshot<User> user) {
                        if (user.hasData) {
                          if (user.data != null) {
                            if (user.data.profileImageUrl != "") {
                              return Image(
                                fit: BoxFit.fitWidth,
                                image: CachedNetworkImageProvider(
                                    user.data.profileImageUrl),
                              );
                            } else {
                              return new Image(
                                fit: BoxFit.fitWidth,
                                image: ExactAssetImage("images/anonym.png"),
                              );
                            }
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    )),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                      onPressed: _signOut, icon: Icon(Icons.time_to_leave)),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(3.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: .5,
                                spreadRadius: 1.0,
                                color: Colors.black.withOpacity(.12))
                          ],
                          color: Color.fromARGB(50, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Text(
                              "Peter Zwegert",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        new SliverList(
          delegate: new SliverChildBuilderDelegate(
              (context, index) => new Card(
                      child: new Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: new CachedNetworkImageProvider(
                                  'http://i.pravatar.cc/40'),
                            ),
                            SizedBox(width: 15.0),
                            Text('I am the card content!!')
                          ],
                        ),
                      ],
                    ),
                  )),
              childCount: 10),
        )
      ],
    ));
  }

  _signOut() async {
    try {
      await Auth().signOut();
    } catch (e) {
      print(e);
    }
  }
}
