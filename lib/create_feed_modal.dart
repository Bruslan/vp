import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateFeedModal extends StatelessWidget {
  const CreateFeedModal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text("create Feed"),
      ),
      body: Text("hallo"),
    );
  }
}
