import 'package:es_app/authenticate/login.dart';
import 'package:es_app/authenticate/signin.dart';
import 'package:flutter/material.dart';
import 'package:es_app/home/index.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  void toggleView(){
    setState(() => showLogIn = !showLogIn);
  }

  @override
  Widget build(BuildContext context) {
    if(showLogIn){
      return Login(toggleView: toggleView);
    } else {
      return SigninPage(toggleView: toggleView);
    }
  }
}
