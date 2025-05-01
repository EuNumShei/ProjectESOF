import 'package:es_app/home/client/home.dart';
import 'package:flutter/material.dart';
import 'package:es_app/services/database.dart';
import 'package:es_app/home/cook/cookstatistics.dart';


class MainWrapper extends StatelessWidget {
  final String? uid;

  const MainWrapper({required this.uid});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService(uid: uid);

    return FutureBuilder<String>(
      future: dbService.getUserStatus(uid),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error if there is any
        } else if (snapshot.hasData && snapshot.data == 'client') {
          return const RestaurantSelectionPage();
        } else if (snapshot.hasData && snapshot.data == 'cook'){
          return const CookStatisticsPage();
        } else {
          return Text('User not found or status not set'); // Default case
        }
      },
    );
  }
}