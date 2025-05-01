import 'package:es_app/authenticate/authenticate.dart';
import 'package:es_app/home/client/home.dart';
import 'package:es_app/mainwrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:es_app/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    if(user == null){
      return Authenticate();
    } else{
      return MainWrapper(uid: user.uid);
    }
  }
}