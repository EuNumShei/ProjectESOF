import 'package:es_app/services/auth.dart';
import 'package:es_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
  SigninPage({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  Color clientButtonColor = Colors.white; // Initial color for Client button
  Color cookButtonColor = Colors.white; // Initial color for Cook button
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool client = false;
  bool cook = false;
  String? selectedRestaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text('Sign In',
            style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor:
            Color.fromARGB(255, 199, 170, 127), // Background color of the title
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.login_outlined),
              onPressed: () {
                widget.toggleView();
              })
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(199, 170, 127, 1.0), // Background color
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Write your institutional email address and password in order to sign in to the app',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40),
                          TextFormField(
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter an email' : null,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  color: Colors.black), // Text color
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              }),
                          const SizedBox(height: 20.0),
                          TextFormField(
                              validator: (val) =>
                                  (val!.isEmpty) ? 'Enter a password' : null,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              style: const TextStyle(
                                  color: Colors.black), // Text color
                              onChanged: (val) {
                                setState(() {
                                  password = val;
                                });
                              }),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Type of user',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    client = !client;
                                    clientButtonColor =
                                        client ? Colors.grey : Colors.white;
                                    cook = false;
                                    cookButtonColor = Colors.white;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.grey;
                                      }
                                      return clientButtonColor;
                                    },
                                  ),
                                ),
                                child: const Text('Client'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    cook = !cook;
                                    cookButtonColor =
                                        cook ? Colors.grey : Colors.white;
                                    client = false;
                                    clientButtonColor = Colors.white;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.grey;
                                      }
                                      return cookButtonColor;
                                    },
                                  ),
                                ),
                                child: const Text('Cook'),
                              ),
                            ],
                          ),
                          if (cook)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select where you work',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  value: selectedRestaurant,
                                  items: [
                                    'Canteen',
                                    'Engineering Grill',
                                    'Mina\'s Bar',
                                    'Library\'s Bar'
                                  ]
                                      .map((restaurant) =>
                                          DropdownMenuItem<String>(
                                            value: restaurant,
                                            child: Text(restaurant),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedRestaurant = val;
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? 'Please select a restaurant'
                                      : null,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (client == true && cook == false) {
                                if (_formKey.currentState!.validate()) {
                                  dynamic res = await _auth.signinEmailPassword(
                                      email, password, 'client', '');
                                  if (res == null) {
                                    setState(() {
                                      error =
                                          'Could not sign in with those credentials';
                                    });
                                  }
                                }
                              } else if (cook == true && client == false) {
                                if (_formKey.currentState!.validate()) {
                                  if (selectedRestaurant == null) {
                                    setState(() {
                                      error = 'Select the restaurant';
                                    });
                                    return;
                                  }
                                  dynamic res = await _auth.signinEmailPassword(
                                      email,
                                      password,
                                      'cook',
                                      selectedRestaurant!);
                                  if (res == null) {
                                    setState(() {
                                      error =
                                          'Could not sign in with those credentials';
                                    });
                                  }
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'Please select one type of user'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text('Sign In'),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            error,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
