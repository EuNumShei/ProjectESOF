import 'package:flutter/material.dart';
import 'package:es_app/services/database.dart';

class StartClientMenuPage extends StatefulWidget {
  const StartClientMenuPage({Key? key}) : super(key: key);
  @override
  _StartClientMenuPageState createState() => _StartClientMenuPageState();
}

class _StartClientMenuPageState extends State<StartClientMenuPage> {
  final DatabaseService _databaseService = DatabaseService();

  String restaurant1 = "Canteen";
  String restaurant2 = "Engineering Grill";
  String restaurant3 = "Library Bar";
  String restaurant4 = "Minas Bar";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteQ'),
        backgroundColor: const Color.fromRGBO(163, 163, 67, 1.0),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
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
                Navigator.pushReplacementNamed(context, '/clientmenuview');
              },
              child: Text(
                restaurant1,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: Color.fromARGB(255, 125, 125, 125), width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant2;
                Navigator.pushReplacementNamed(context, '/clientmenuview');
              },
              child: Text(
                restaurant2,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: Color.fromARGB(255, 125, 125, 125), width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant3;
                Navigator.pushReplacementNamed(context, '/clientmenuview');
              },
              child: Text(
                restaurant3,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: Color.fromARGB(255, 125, 125, 125), width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
            SizedBox(height: 80.0),
            ElevatedButton(
              onPressed: () {
                client_restaurant_menu = restaurant4;
                Navigator.pushReplacementNamed(context, '/clientmenuview');
              },
              child: Text(
                restaurant4,
                style: TextStyle(fontSize: 18.0),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(BorderSide(color: Color.fromARGB(255, 125, 125, 125), width: 2)),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
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
}