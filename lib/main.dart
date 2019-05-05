import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/login/root_screen.dart';
import 'auth_class.dart';
import 'package:vp/login/sign_in_screen.dart';

import 'package:vp/login/sign_up_screen.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VayNaxGram',
            routes: <String, WidgetBuilder>{
        '/signup': (BuildContext context) => new SignUpScreen(),
        '/root': (BuildContext context) => new RootScreen(),
        '/signin': (BuildContext context) => new SignInScreen(),
       
        
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootScreen(),
    );
  }
}
