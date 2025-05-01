import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingTimesPage extends StatefulWidget {
  const WaitingTimesPage({Key? key}) : super(key: key);

  @override
  _WaitingTimesPage createState() => _WaitingTimesPage();
}

class _WaitingTimesPage extends State<WaitingTimesPage> {
  late CollectionReference _restaurantsRef;
  List<MapEntry<String, num>> waitingTimes = [];
  String restaurant = '';
  num waitingTime = 0;

  @override
  void initState() {
    super.initState();
    _restaurantsRef = FirebaseFirestore.instance.collection('restaurants');
    _getDataFromFirebase();
  }

  void _getDataFromFirebase() {
  for (int i = 1; i < 5; i++) {
    String idr = i.toString();
    _restaurantsRef.doc(idr).get().then((DocumentSnapshot document) {
      if (document.exists) {
        Map<String, dynamic>? restaurantName = document.data() as Map<String, dynamic>?;

        if (restaurantName != null && restaurantName.containsKey('name')) {
          restaurant = restaurantName['name'] as String;
        }

        Map<String, dynamic>? waitingTimesData = document.data() as Map<String, dynamic>?;
        if (waitingTimesData != null && waitingTimesData.containsKey('waiting_time')) {
          waitingTime = waitingTimesData['waiting_time'] as num;
        }

        setState(() {
          waitingTimes.add(MapEntry(restaurant, waitingTime));
        });
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // Convertendo o Map em uma lista de pares (nome, tempo)
    List<MapEntry<String, num>> sortedWaitingTimes = waitingTimes.toList();

    // Ordena a lista com base nos tempos de espera
    sortedWaitingTimes.sort((a, b) {
      int timeA = a.value.toInt();
      int timeB = b.value.toInt();
      return timeA.compareTo(timeB);
    });

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Waiting Times:',style: TextStyle(fontSize: 30)),
            SizedBox(height: 20),
            Column(
              children: waitingTimes.map((entry) {
                return Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.key}:          ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                            text: entry.value > 1 ? '${entry.value} minutes' : '${entry.value} minute',
                            style: TextStyle(fontSize: 18, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'According to our cost x waiting time ratio, here are our suggestions in order',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // Adicionando negrito
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            for (var entry in sortedWaitingTimes) ...[
              Text(
                '${entry.key}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
            ],
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
                onPressed: () {},
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