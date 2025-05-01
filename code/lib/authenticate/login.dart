import 'package:flutter/material.dart';
import 'package:es_app/services/auth.dart';

class Login extends StatefulWidget {
  final Function toggleView;
  Login({Key? key, required this.toggleView}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text('Log In',style: TextStyle(fontSize: 30,color: Colors.black,fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 199, 170, 127),
        actions: <Widget>[
          IconButton(
            icon : Icon(Icons.login_outlined),
            onPressed: () {
              widget.toggleView();
            }
          )
        ], // Background color of the title
      ),
      body: Container(
        color: const Color.fromRGBO(199, 170, 127, 1.0), // Background color
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Write your institutional email address and password in order to log in to the app',
                    style: TextStyle(fontSize: 20,color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    validator: (val) => (val!.isEmpty) ? 'Enter an email' : null,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.black), // Text color
                    onChanged: (val){
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (val) => (val!.isEmpty) ? 'Enter a password' : null,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.black), // Text color
                    onChanged: (val){
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  const SizedBox(height: 150),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          // Implement sign-in functionality for cook here
                          // Navigate to the home page on successful sign-in
                          Navigator.pushReplacementNamed(context, '/index');
                        },
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: 50),
                      ElevatedButton(
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            dynamic res = await _auth.loginEmailPassword(email, password);
                            if(res == null){
                              setState(() {
                                error = 'Could not log in with those credentials';
                              });
                            }
                          }
                        },
                        child: const Text('Log In'),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}