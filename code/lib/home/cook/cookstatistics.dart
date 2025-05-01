import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:es_app/services/calendar.dart';

class CookStatisticsPage extends StatefulWidget {
  const CookStatisticsPage({Key? key}) : super(key: key);

  @override
  _CookStatisticsPageState createState() => _CookStatisticsPageState();
}

class _CookStatisticsPageState extends State<CookStatisticsPage> {
  late CollectionReference _restaurantRef;
  late CollectionReference _statsRef;
  List<MapEntry<String, num>> clientsPerDay = [];
  List<MapEntry<String, num>> satisfactionPerDay = [];
  String restaurant = '';
  int id_restaurant = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _restaurantRef = FirebaseFirestore.instance.collection('users');
    _statsRef = FirebaseFirestore.instance.collection('restaurants');
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() async {
  final restaurantDoc = await _restaurantRef.doc(_auth.currentUser?.uid).get();
  if (restaurantDoc.exists) {
    var data = restaurantDoc.data() as Map<String, dynamic>;
    if (data.containsKey('restaurant')) {
      setState(() {
        restaurant = data['restaurant'].toString();
      });
    }
  }

  for (int i = 1; i < 5; i++) {
    String idr = i.toString();
    final statsDoc = await _statsRef.doc(idr).get();
    if (statsDoc.exists) {
      var data = statsDoc.data() as Map<String, dynamic>;
      if (data.containsKey('name') && restaurant == data['name'].toString()) {
        id_restaurant = i;

        //String weekday = get_weekday();
        final currentSemester = getSchoolYear();
        final currentMonthWeek = getCurrentMonthWeek();

        String clientsPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/stats/clients_per_day";
  
        final clientsDocRef = await _statsRef.doc(clientsPath);
  
        final clientsDocSnapshot = await clientsDocRef.get();
        if (clientsDocSnapshot.exists) {
          // Documento existe
          var clientsData = clientsDocSnapshot.data() as Map<String, dynamic>;
          clientsData.forEach((key, value) {
            if (value is num) {
              clientsPerDay.add(MapEntry(key, value));
            }
          });
          clientsPerDay.sort((a, b) => getDayOfWeekNumber(a.key).compareTo(getDayOfWeekNumber(b.key)));
          setState(() {});
        }

        String satisfactionPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/stats/satisfaction_per_day";

        final satisfactionDocRef = await _statsRef.doc(satisfactionPath);

        final satisfactionDocSnapshot = await satisfactionDocRef.get();

        if (satisfactionDocSnapshot.exists) {

          var satisfactionData = satisfactionDocSnapshot.data() as Map<String, dynamic>;
          satisfactionData.forEach((key, value) {
            if (value is num) {
              satisfactionPerDay.add(MapEntry(key, value));
            }
          });
          satisfactionPerDay.sort((a, b) => getDayOfWeekNumber(a.key).compareTo(getDayOfWeekNumber(b.key)));
          setState(() {});
        }
      }
    }
  }
}

  Widget _buildChart() {
    return charts.BarChart(
      _createChartData(clientsPerDay, satisfactionPerDay),
      animate: true,
      vertical: true,
      //barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
        renderSpec: charts.GridlineRendererSpec(
          labelAnchor: charts.TickLabelAnchor.inside,
          labelJustification: charts.TickLabelJustification.inside,
        ),
      ),
      behaviors: [
        charts.SeriesLegend(),
      ],
    );
  }

List<charts.Series<MapEntry<String, num>, String>> _createChartData(
  List<MapEntry<String, num>> clientsPerDay, List<MapEntry<String, num>> satisfactionPerDay) {

  String _abbreviateDay(String day) {
    return day.substring(0, 3); // Abreviando para as três primeiras letras
  }

  var clientsData = <charts.Series<MapEntry<String, num>, String>>[];
  clientsData.add(
    charts.Series<MapEntry<String, num>, String>(
      id: 'Clients',
      data: clientsPerDay,
      domainFn: (entry, _) => _abbreviateDay(entry.key),
      measureFn: (entry, _) => entry.value,
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    ),
  );
  var satisfactionData = <charts.Series<MapEntry<String, num>, String>>[];
  satisfactionData.add(
    charts.Series<MapEntry<String, num>, String>(
      id: 'Satisfaction',
      data: satisfactionPerDay,
      domainFn: (entry, _) => _abbreviateDay(entry.key),
      measureFn: (entry, _) => entry.value,
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
    ),
  );
  return clientsData + satisfactionData;
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
      body: Center(
        child: SingleChildScrollView( // Adicionei o SingleChildScrollView para evitar overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Statistics:', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Text('$restaurant', style: const TextStyle(fontSize: 25)),
              const SizedBox(height: 20),
              Column(
                children: clientsPerDay.map((entry) {
                  return Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${entry.key}:          ',
                              style: const TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            TextSpan(
                              text: entry.value > 1 ? '${entry.value} clients' : '${entry.value} client',
                              style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 50, 150, 200)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text('Attendance:', style: TextStyle(fontSize: 25, color: Colors.black)),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: 600, // Aumentei a largura do Container
                padding: const EdgeInsets.all(16),
                child: _buildChart(),
              ),
              /*const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 125, 125, 125), width: 2),
                  borderRadius: BorderRadius.circular(20.0), // Ajustei o border radius conforme necessário
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    '< Client example >',
                    textAlign: TextAlign.right,  // Movi a propriedade textAlign para cá
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ), 
                  ),
                ),
              )*/
            ],
          ),
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
              onPressed: () {},
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