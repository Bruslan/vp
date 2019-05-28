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
  int currentVote = 0;

  _userHasVoted() async {
    int vote = await userHasVotedThisFeed(widget.feedId, widget.currentUserID);
    setState(() {
      hasVoted = vote;
    });
  }

  _upVoteTheFeed() async {
    await incrementFeedVote(widget.feedId, "upVotes");
    userHasVotedFeed(widget.feedId, widget.currentUserID, 1);
  }

  _downVote() async {
    await incrementFeedVote(widget.feedId, "downVotes");
    userHasVotedFeed(widget.feedId, widget.currentUserID, -1);
  }

  _deleteCurrentVote(String voteString) async {
    await decrementFeedVote(widget.feedId, voteString);
    deleteUserVoteForFeed(widget.feedId, widget.currentUserID);
  }

  _deleteCurrentVoteAndIncrementOther(
      String lastVote, String newVote, int changeTo) async {
    await decrementFeedVote(widget.feedId, lastVote);
    await incrementFeedVote(widget.feedId, newVote);
    userHasVotedFeed(widget.feedId, widget.currentUserID, changeTo);
  }

  _buildCount() {
    voteDifference = widget.upVotes - widget.downVotes;
    return Text((voteDifference + currentVote).toString());
  }

  @override
  Widget build(BuildContext context) {
    _userHasVoted();
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
            color: hasVoted == 1 ? Colors.green : Colors.grey,
            onPressed: () {
              switch (hasVoted) {
                case -1:
                  {
                    setState(() {
                      // hat zuvor upvote geklickt
                      _deleteCurrentVoteAndIncrementOther(
                          "downVotes", "upVotes", 1);
                      hasVoted = 1;
                      currentVote += 2;
                    });
                  }
                  break;
                case 0:
                  {
                    // hat noch keinen Vote gemacht
                    setState(() {
                      _upVoteTheFeed();
                      hasVoted = 1;
                      currentVote += 1;
                    });
                  }
                  break;
                case 1:
                  {
                    //  hat davor downGevotet
                    setState(() {
                      // hat zuvor upvote geklickt
                      _deleteCurrentVote("upVotes");
                      hasVoted = 0;
                      currentVote -= 1;
                    });
                  }

                  break;
                default:
              }
            },
            icon: Icon(Icons.keyboard_arrow_up),
          ),
          _buildCount(),
          IconButton(
            color: hasVoted == -1 ? Colors.red : Colors.grey,
            onPressed: () {
              switch (hasVoted) {
                case 1:
                  {
                    setState(() {
                      // hat zuvor upvote geklickt
                      _deleteCurrentVoteAndIncrementOther(
                          "upVotes", "downVotes", -1);
                      hasVoted = -1;
                      currentVote -= 2;
                    });
                  }
                  break;
                case 0:
                  {
                    // hat noch keinen Vote gemacht
                    setState(() {
                      _downVote();
                      hasVoted = -1;
                      currentVote -= 1;
                    });
                  }
                  break;
                case -1:
                  {
                    //  hat davor downGevotet
                    setState(() {
                      // hat zuvor upvote geklickt
                      _deleteCurrentVote("downVotes");
                      hasVoted = 0;
                      currentVote += 1;
                    });
                  }

                  break;
                default:
              }
            },
            icon: Icon(Icons.keyboard_arrow_down),
          )
        ],
      ),
    );
  }
}
