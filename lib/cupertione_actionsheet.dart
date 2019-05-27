import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void containerForSheet<T>({BuildContext context, Widget child}) {
  showCupertinoModalPopup<T>(
    context: context,
    builder: (BuildContext newcontext) => child,
  ).then<void>((T value) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('You clicked $value'),
      duration: Duration(milliseconds: 800),
    ));
  });
}
