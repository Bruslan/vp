import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database_logic.dart';

class Votes extends StatefulWidget {
  final String feedId;
  final int upVotes;
  final int downVotes;
  final String currentUserID;
  Votes(
      {Key key, this.feedId, this.upVotes, this.downVotes, this.currentUserID})
      : super(key: key);

  _VotesState createState() => _VotesState();
}

class _VotesState extends State<Votes> {
  int hasVoted = 0;

  _userHasVoted() async {
    int vote = await userHasVotedThisFeed(widget.feedId, widget.currentUserID);
    setState(() {
      hasVoted = vote;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userHasVoted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
            color: hasVoted == 1 ? Colors.green : Colors.grey,
            onPressed: () {
              setState(() {
                hasVoted = 1;
              });
            },
            icon: Icon(Icons.keyboard_arrow_up),
          ),
          Text("12"),
          IconButton(
            color: hasVoted == -1 ? Colors.red : Colors.grey,
            onPressed: () {
              setState(() {
                hasVoted = -1;
              });
            },
            icon: Icon(Icons.keyboard_arrow_down),
          )
        ],
      ),
    );
  }
}
