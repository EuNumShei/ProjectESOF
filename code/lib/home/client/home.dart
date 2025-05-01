import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantSelectionPage extends StatefulWidget {
  const RestaurantSelectionPage({Key? key}) : super(key: key);

  @override
  State<RestaurantSelectionPage> createState() =>
      _RestaurantSelectionPageState();
}

class _RestaurantSelectionPageState extends State<RestaurantSelectionPage> {
  final DatabaseService _databaseService = DatabaseService();
  String? selectedRestaurant;
  bool isExpanded = false;

  Future<void> _updateUserRestaurant() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedRestaurant != null) {
      await _databaseService.updateUserRestaurant(
          user.uid, selectedRestaurant!);
    }
  }

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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 700,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text(
                            '  Select where you\'ll eat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          value: selectedRestaurant,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRestaurant = newValue;
                            });
                          },
                          items: snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['name'],
                              child: Text(doc['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await _updateUserRestaurant();
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFE7E75D)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.all(10.0),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Restaurants',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Primeira linha com os dois primeiros itens
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.docs.take(2).map((doc) {
                          return GestureDetector(
                            onTap: () async {
                              client_restaurant_menu = doc['name'];
                              Navigator.pushReplacementNamed(context, '/clientmenuview');
                              setState(() {
                                selectedRestaurant = doc['name'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 120,
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 90,
                                    height: 70,
                                    child: Image.asset('images/${doc['name']}.png'),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    doc['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).expand((widget) => [widget, SizedBox(width: 20)]).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Segunda linha com os restantes dos itens
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.docs.skip(2).map((doc) {
                          return GestureDetector(
                            onTap: () async {
                              client_restaurant_menu = doc['name'];
                              Navigator.pushReplacementNamed(context, '/clientmenuview');
                              setState(() {
                                selectedRestaurant = doc['name'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 120,
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 90,
                                    height: 70,
                                    child: Image.asset('images/${doc['name']}.png'),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    doc['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).expand((widget) => [widget, SizedBox(width: 20)]).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
              onPressed: () {},
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
