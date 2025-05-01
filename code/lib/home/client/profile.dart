import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() =>_ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late CollectionReference _usersRef;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "";
  String status = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    _usersRef = FirebaseFirestore.instance.collection('users');
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() {
    _usersRef.doc(_auth.currentUser?.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        var data = document.data() as Map<String, dynamic>;

        // Verificar a existência da chave restaurant
        if (data.containsKey('email') && data.containsKey('status')) {
          setState(() {
            email = data['email'].toString();
            status = data['status'].toString();
            password = data['password'].toString();
        });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteQ'),
        backgroundColor: const Color.fromRGBO(163, 163, 67, 1.0),
        actions: [
          IconButton(
            icon : Icon(Icons.login_outlined),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/wrapper');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Status:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '   $status',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Email:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              title: Text(
                  email,
                  style: TextStyle(fontSize: 18),
                ),
            ),
            SizedBox(height: 24),
            Text(
              'Password:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              title: Text(
                  _obscurePassword(password),
                  style: TextStyle(fontSize: 18),
                ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(163, 163, 67, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.feedback),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/feedback');
                },
              ),
              IconButton(
                icon: const Icon(Icons.schedule),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/waitingtimes');
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              IconButton(
                icon: const Icon(Icons.restaurant_menu),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/clientstartmenu');
                },
              ),
            ],
          ),
        ),
    );
  }
  String _obscurePassword(String password) {
    return '*' * password.length; // Substitui cada caractere por um asterisco
  }
}