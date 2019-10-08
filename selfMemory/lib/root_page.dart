import 'package:flutter/materiaL.dart';

import 'login_page.dart';
import 'auth.dart';
import 'home_page.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus{
  notLoggedIn,
  loggedIn
}

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus= AuthStatus.notLoggedIn;
  String uID;

@override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userID){
      setState(() {
        uID= userID;
      });
    });
  }

  void _loggedIn(){
    setState(() {
     _authStatus= AuthStatus.loggedIn; 
     widget.auth.currentUser().then((userID){
       setState(() {
        uID= userID; 
       });
     });
    });
  }

  void _loggedOut(){
    setState(() {
     _authStatus = AuthStatus.notLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notLoggedIn:
        return new LoginPage(
          auth: widget.auth,
          onLoggedIn: _loggedIn,
          );
      case AuthStatus.loggedIn:
        return new HomePage(
          auth: widget.auth,
          onLoggedOut: _loggedOut,
          uID: uID,
        );
    }
    
  }
}