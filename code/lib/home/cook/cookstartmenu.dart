import 'package:flutter/material.dart';
import 'package:es_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartCookMenuPage extends StatefulWidget {
  const StartCookMenuPage({Key? key}) : super(key: key);
  @override
  _StartCookMenuPageState createState() => _StartCookMenuPageState();
}

class _StartCookMenuPageState extends State<StartCookMenuPage> {
  final DatabaseService _databaseService = DatabaseService();
  late CollectionReference _statisticsRef;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String restaurant1 = "Canteen";
  String restaurant2 = "Engineering Grill";
  String restaurant3 = "Library Bar";
  String restaurant4 = "Minas Bar";
  Color default_color = const Color.fromARGB(255, 125, 125, 125);
  Color cook_color = const Color.fromRGBO(163, 67, 67, 1.0);

  @override
  void initState() {
    super.initState();
    _statisticsRef = FirebaseFirestore.instance.collection('users');
    _getDataFromFirestore();
  }

  Future<void> _getDataFromFirestore() async {
    try {
      DocumentSnapshot document = await _statisticsRef.doc(_auth.currentUser?.uid).get();
      if (document.exists) {
        var data = document.data() as Map<String, dynamic>;
        
        if (data.containsKey('restaurant')) {
          final restaurantValue = data['restaurant'].toString();
          if (mounted) {
            setState(() {
              cook_restaurant = restaurantValue;
            });
          }
        }
      }
    } catch (e) {
      print('Error getting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteQ'),
        backgroundColor: const Color.fromRGBO(163, 67, 67, 1.0),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/cookprofile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a Restaurant:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
            ),
            SizedBox(height: 40.0), // Adiciona um espaço entre o título e os botões
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant1;
                if (cook_restaurant == restaurant1)
                  Navigator.pushReplacementNamed(context, '/cookmenu');
                else {
                  Navigator.pushReplacementNamed(context, '/cookmenuview');
                }
              },
              child: Text(
                restaurant1,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: cook_restaurant == restaurant2 ? cook_color: default_color, width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant2;
                if (cook_restaurant == restaurant2)
                  Navigator.pushReplacementNamed(context, '/cookmenu');
                else {
                  Navigator.pushReplacementNamed(context, '/cookmenuview');
                }
              },
              child: Text(
                restaurant2,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: cook_restaurant == restaurant2 ? cook_color: default_color, width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant3;
                if (cook_restaurant == restaurant3)
                  Navigator.pushReplacementNamed(context, '/cookmenu');
                else {
                  Navigator.pushReplacementNamed(context, '/cookmenuview');
                }
              },
              child: Text(
                restaurant3,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: cook_restaurant == restaurant2 ? cook_color: default_color, width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant4;
                if (cook_restaurant == restaurant4)
                  Navigator.pushReplacementNamed(context, '/cookmenu');
                else {
                  Navigator.pushReplacementNamed(context, '/cookmenuview');
                }
              },
              child: Text(
                restaurant4,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: cook_restaurant == restaurant2 ? cook_color: default_color, width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(163, 67, 67, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cookfeedback');
              },
            ),
            IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cookwaitingtimes');
              },
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cookstatistics');
              },
            ),
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/cookstartmenu');
              },
            ),
          ],
        ),
      ),
    );
  }
}