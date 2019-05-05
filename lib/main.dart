import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'root_page.dart';

import 'auth_class.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VayNaxGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(auth: new Auth()),
    );
  }
}
