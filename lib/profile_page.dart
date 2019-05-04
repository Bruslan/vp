import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key}) : super(key: key);

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
                    child: Image.network(
                      'http://i.pravatar.cc/800',
                      fit: BoxFit.fitWidth,
                    )),
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
                              backgroundImage:
                                  new NetworkImage('http://i.pravatar.cc/50'),
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
