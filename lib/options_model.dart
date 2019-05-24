import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database_logic.dart';

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
  final int commentCount;

  FeedModel(
      {this.commentCount,
      this.options,
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
        commentCount: json["commentCount"],
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
      "commentCount": commentCount,
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

class Options extends StatefulWidget {
  final String feedId;
  Options({Key key, this.feedId}) : super(key: key);

  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getOptionsForFeed(widget.feedId),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          Map<String, dynamic> options = new Map();
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              print(snapshot.data.data);
              options = snapshot.data.data;
              return _buildOptions(options);
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
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

  Widget _calculateOptionPercentage(int index) {
    final testMap = [90, 10, 80, 22];

    return Text(testMap[index].toString() + "%");
  }

  _buildOptions(Map<String, dynamic> options) {
    List optionsList = new List();
    options.forEach((key, value) {
      optionsList.add(key);
    });
    return Container(
      height: options.length.toDouble() * 50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
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
                    Text(optionsList[index]),
                  ],
                ),
                _showOptionPercentage
                    ? _calculateOptionPercentage(index)
                    : SizedBox()
              ],
            ),
          );
        },
      ),
    );
  }
}
