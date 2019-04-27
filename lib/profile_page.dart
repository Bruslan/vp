import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("Profile"),
        ),
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
                      
                      child: Image.network('http://i.pravatar.cc/800', fit: BoxFit.fitWidth,)),
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
                                  backgroundImage: new NetworkImage(
                                      'http://i.pravatar.cc/300'),
                                ),
                                SizedBox(width: 15.0),
                                Text('I am the card content!!')
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.favorite_border,
                                size: 15,
                              ),
                            )
                          ],
                        ),
                      )),
                  childCount: 10),
            )
          ],
        ));
  }
}
