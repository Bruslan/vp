import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vp/chat_page.dart';
import 'package:vp/database_logic.dart';
import 'package:vp/models/user_model.dart';
import 'auth_class.dart';
import "cupertione_actionsheet.dart";

class ProfilePage extends StatefulWidget {
  final String targetUserId;
  final bool currentUser;
  const ProfilePage({Key key, this.targetUserId, @required this.currentUser})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void changeProfilePicture(File imageFile) async {
    uploadImage(imageFile).then((downLoadUrl) {
      updateProfilePicture(widget.targetUserId, downLoadUrl).then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _signOut() async {
      Navigator.of(context, rootNavigator: true).pop();
      try {
        await Auth().signOut();
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    }

    _buildSentButton() {
      return IconButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => ChatPage(targetUserID: widget.targetUserId),
          ));
        },
        icon: Icon(
          CupertinoIcons.mail,
          color: Colors.white,
        ),
      );
    }

    Widget _buildProfileImage() {
      return FutureBuilder(
        future: getUserProfile(widget.targetUserId),
        builder: (BuildContext context, AsyncSnapshot<User> user) {
          if (user.hasData) {
            if (user.data != null) {
              if (user.data.profileImageUrl != "") {
                return Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Image(
                        fit: BoxFit.fitWidth,
                        image: CachedNetworkImageProvider(
                            user.data.profileImageUrl),
                      ),
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
                                    color: Colors.black.withOpacity(.22))
                              ],
                              color: Color.fromARGB(150, 0, 0, 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  user.data.userName,
                                  style: TextStyle(color: Colors.white),
                                ),
                                widget.currentUser == true
                                    ? Container()
                                    : _buildSentButton()
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    new Image(
                      fit: BoxFit.fitWidth,
                      image: ExactAssetImage("images/anonym.png"),
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
                                    color: Colors.black.withOpacity(.22))
                              ],
                              color: Color.fromARGB(150, 0, 0, 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Text(
                              user.data.userName,
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    }

    Widget buildProfileMenu() {
      return Column(
        children: <Widget>[
          new ListTile(
              leading: new Icon(Icons.directions_walk),
              title: new Text('Abmelden'),
              onTap: _signOut),
          new ListTile(
              leading: new Icon(Icons.image),
              title: new Text('Change Profile Picture'),
              onTap: () async {
                File imageFile = await ImagePicker.pickImage(
                    source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

                if (imageFile != null) {
                  changeProfilePicture(imageFile);

                  Navigator.of(context).pop();
                }
              }),
        ],
      );
    }

    Widget buildProfileMenuCupertino() {
      return Column(
        children: <Widget>[
          new CupertinoActionSheetAction(
              child: new Text('Abmelden'), onPressed: _signOut),
          new CupertinoActionSheetAction(
              child: new Text('Change Profile Picture'),
              onPressed: () async {
                File imageFile = await ImagePicker.pickImage(
                    source: ImageSource.gallery, maxHeight: 600, maxWidth: 600);

                if (imageFile != null) {
                  changeProfilePicture(imageFile);

                  Navigator.of(context, rootNavigator: true).pop();
                }
              }),
        ],
      );
    }

    Widget _menuButton() {
      return Positioned(
        top: 10,
        right: 10,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // margin: const EdgeInsets.all(3.0),
                // padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: .5,
                        spreadRadius: 1.0,
                        color: Colors.black.withOpacity(.22))
                  ],
                  color: Color.fromARGB(150, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        containerForSheet<String>(
                            context: context,
                            child: CupertinoActionSheet(
                                title: const Text('Was wollen Sie tun?'),
                                // message: const Text('Your options are '),
                                actions: <Widget>[
                                  buildProfileMenuCupertino(),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  child: const Text('Cancel'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop("Discard");
                                  },
                                )));
                        ;
                      },
                      icon: Icon(Icons.settings),
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return new Scaffold(
        // appBar: CupertinoNavigationBar(
        //   middle: Text("Profile"),
        // ),
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
                  child: _buildProfileImage(),
                ),
                widget.currentUser ? _menuButton() : Container(),
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
}
