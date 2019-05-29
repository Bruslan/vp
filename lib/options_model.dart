import 'dart:math';

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
  final String currentUser;
  Options({Key key, this.feedId, this.currentUser}) : super(key: key);

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
              options = snapshot.data.data;
              return _buildOptions(options);
            }
          } else {
            return SizedBox(
            height: options.length.toDouble() * 50,
          );
          }
        },
      ),
    );
  }

  int _radioValue = -1;
  bool _showOptionPercentage = false;

  void _handleRadioValueChange(
      int value, String votedOption, String currentVote) {
    _showOptionPercentage = true;
    if(mounted){
    setState(() {
      _radioValue = value;
    });
    }


//     if (votedOption == currentVote) {
//       // remove the vote
//       decrementoptionVote(widget.feedId, votedOption).then((_) {
//         userhasDeletedVote(widget.feedId, widget.currentUser, votedOption);
//       });
//     } else if (currentVote == "") {
//       // ganz einfaches Increment
//       incrementOptionVote(widget.feedId, votedOption).then((_) {
//         userhasVoted(widget.feedId, widget.currentUser, votedOption);
//       });
//     } else if (currentVote != "") {
// // increment auf current Vote löschen und auf votedOption stellen
//       decrementoptionVote(widget.feedId, currentVote);
//       incrementOptionVote(widget.feedId, votedOption).then((_) {
//         userhasVoted(widget.feedId, widget.currentUser, votedOption);
//       });
//     }
//     setState(() {

//     });
  }

  Widget _calculateOptionPercentage(int index, int votingCount) {
    // final testMap = [90, 10, 80, 22];

    return Text(votingCount.toString());
  }

  _buildOptions(Map<String, dynamic> options) {
    List optionsList = new List();
    options.forEach((key, value) {
      optionsList.add(key);
    });
    return FutureBuilder(
      future: userHasVotedThisOption(widget.feedId, widget.currentUser),
      builder: (BuildContext context, AsyncSnapshot option) {
        if (option.hasData) {
          if (option.data != "") {
            _radioValue = optionsList.indexOf(option.data);
            _showOptionPercentage = true;
          }

          return Container(
            height: options.length.toDouble() * 50,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return FlatButton(
                  onPressed: () {
                    _handleRadioValueChange(
                        index, optionsList[index], option.data);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Radio(
                            groupValue: _radioValue,
                            onChanged: (_) {
                              _handleRadioValueChange(
                                  index, optionsList[index], option.data);
                            },
                            value: index,
                          ),
                          Text(optionsList[index]),
                        ],
                      ),
                      _showOptionPercentage
                          ? _calculateOptionPercentage(
                              index, options[optionsList[index]])
                          : SizedBox()
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return SizedBox(
            height: options.length.toDouble() * 50,
          );
        }
      },
    );
  }
}
