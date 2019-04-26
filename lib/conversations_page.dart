import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Conversations extends StatelessWidget {
  const Conversations({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text("create"),
      ),
      body: Container()
    );
  }
}
