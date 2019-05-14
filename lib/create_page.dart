import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CreatePage extends StatelessWidget {
  const CreatePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("Create your Feed"),
        ),
        body: CreateContentListView(),
      ),
    );
  }
}

class CreateContentListView extends StatefulWidget {
  CreateContentListView({Key key}) : super(key: key);

  _CreateContentListViewState createState() => _CreateContentListViewState();
}

class _CreateContentListViewState extends State<CreateContentListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: ListView(
         children: <Widget>[
           
         ],
       ),
    );
  }
}