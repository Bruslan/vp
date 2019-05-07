import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vp/tabbar.dart';

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new Container(
            color: Colors.white,
          );
        } else {
          if (snapshot.hasData) {
            return InheritedUser(
              fbuser: snapshot.data,
                          child: new TabbarPage(
    
              ),
            );
          } else {
            return SignInScreen();
          }
        }
      },
    );
  }
}


class InheritedUser extends InheritedWidget{


final FirebaseUser fbuser;
  InheritedUser({this.fbuser, Widget child}): super(child:child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return null;
  }

  static InheritedUser of(BuildContext context) =>
  context.inheritFromWidgetOfExactType(InheritedUser);

}
