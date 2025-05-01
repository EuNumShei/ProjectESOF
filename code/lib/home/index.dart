import 'package:flutter/material.dart';

bool showLogIn = true;

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 170, 127, 1.0), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BiteQ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'An app that will save time and food for everybody',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'This App will allow you to know approximate waiting times and menus for the given restaurants as a client, and be able to manage food consumption by statistics as a cook',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showLogIn = false;
                    Navigator.pushReplacementNamed(context, '/wrapper'); // Need to change to a future /signin
                  },
                  child: Text('Sign In'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    showLogIn = true;
                    Navigator.pushReplacementNamed(context, '/wrapper'); // Need to change to a future /login
                  },
                  child: Text('Log In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}