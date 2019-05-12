import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vp/tabbar.dart';
import 'package:vp/login/sign_in_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vp/login/sign_up_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        title: 'VayNaxGram',
        routes: <String, WidgetBuilder>{
          '/signup': (BuildContext context) => new SignUpScreen(),
          '/signin': (BuildContext context) => new SignInScreen(),
        },
        debugShowCheckedModeBanner: false,
        // theme: CupertinoThemeData(
        //   // primarySwatch: Colors.blue,
        // ),
        home: new StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Container(
                color: Colors.white,
              );
            } else {
              if (snapshot.hasData) {
                return TabbarPage(firebaseUser: snapshot.data);
              } else {
                return SignInScreen();
              }
            }
          },
        ));
  }
}
