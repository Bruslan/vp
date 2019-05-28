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
  int voteDifference;
  bool waitTillFinish = false;

  _userHasVoted() async {
    int vote = await userHasVotedThisFeed(widget.feedId, widget.currentUserID);
    setState(() {
      hasVoted = vote;
    });
  }

  _upVoteTheFeed() async {
    incrementFeedVote(widget.feedId, "upVotes");
    userHasVotedFeed(widget.feedId, widget.currentUserID, 1);
  }

  _downVote() async {
    incrementFeedVote(widget.feedId, "downVotes");
    userHasVotedFeed(widget.feedId, widget.currentUserID, -1);
  }

  _deleteCurrentVote(String voteString) async {
    decrementFeedVote(widget.feedId, voteString);
    deleteUserVoteForFeed(widget.feedId, widget.currentUserID);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userHasVoted();
    print(widget.upVotes);
    print(widget.downVotes);
    voteDifference = widget.upVotes - widget.downVotes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
            color: hasVoted == 1 ? Colors.green : Colors.grey,
            onPressed: () {
              if (!waitTillFinish) {
                setState(() {
                  if (hasVoted == 1) {
                    // entferne Vote
                    voteDifference -= 1;
                    hasVoted = 0;
                    _deleteCurrentVote("upVotes");
                  } else {
                    hasVoted = 1;
                    voteDifference += 1;
                    _upVoteTheFeed();
                  }
                });
              }
            },
            icon: Icon(Icons.keyboard_arrow_up),
          ),
          Text(voteDifference.toString()),
          IconButton(
            color: hasVoted == -1 ? Colors.red : Colors.grey,
            onPressed: () {
              if (!waitTillFinish) {
                setState(() {
                  if (hasVoted == -1) {
                    hasVoted = 0;
                    voteDifference += 1;
                    _deleteCurrentVote("downVotes");
                  } else {
                    hasVoted = -1;
                    voteDifference -= 1;
                    _downVote();
                  }
                });
              }
            },
            icon: Icon(Icons.keyboard_arrow_down),
          )
        ],
      ),
    );
  }
}
