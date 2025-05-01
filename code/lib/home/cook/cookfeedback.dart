import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_app/services/FBService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:es_app/services/database.dart';

class CookFeedbackPage extends StatefulWidget {
  const CookFeedbackPage({Key? key}) : super(key: key);

  @override
  _CookFeedbackPage createState() => _CookFeedbackPage();
}

class _CookFeedbackPage extends State<CookFeedbackPage> {
  late CollectionReference _statisticsRef;
  late CollectionReference _restaurantRef;
  TextEditingController _feedbackController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  Color likeButtonColor = Colors.white; // Initial color for Client button
  Color dislikeButtonColor = Colors.white; // Initial color for Cook button
  String restaurant = '';
  bool like = false;
  bool dislike = false;
  String feedback = '';
  String idr = '';
  DateTime current = DateTime.now();


  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _statisticsRef = FirebaseFirestore.instance.collection('users');
    _restaurantRef = FirebaseFirestore.instance.collection('restaurants');
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() {
    _statisticsRef.doc(_auth.currentUser?.uid).get().then((DocumentSnapshot document) async {
      if (document.exists) {
        var data = document.data() as Map<String, dynamic>;

        // Verificar a existência da chave restaurant
        if (data.containsKey('restaurant')) {
          final restaurantValue = data['restaurant'].toString();
          if (mounted) {
            setState(() {
              restaurant = restaurantValue;
            });
          }
          final idsValue = await _databaseService.getIdfromRestaurant(restaurantValue);
          if (mounted) {
            setState(() {
              idr = idsValue.toString();
            });
          }
        }
      }
    });
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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8, // Definindo a largura do Container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Feedback:', style: TextStyle(fontSize: 30)),
                SizedBox(height: 20),
                FutureBuilder<Feedbackk>(
                  future: _databaseService.getReviewsComments(idr),
                  builder: (BuildContext context, AsyncSnapshot<Feedbackk> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('No feedback available.');
                    } else {
                      final feedback = snapshot.data!;
                      if (feedback.likes == null && feedback.dislikes == null && feedback.comments.isEmpty) {
                        return Text('No feedback available.');
                      }

                      // Organizar os comentários por dia
                      Map<int, List<String>> commentsByDay = {};
                      for (var comment in feedback.comments) {
                        final dayMatch = RegExp(r'\(day: (\d+)\)').firstMatch(comment);
                        if (dayMatch != null) {
                          final day = int.parse(dayMatch.group(1)!);
                          final cleanedComment = comment.replaceAll(RegExp(r'\(day: \d+\)'), '').trim();
                          if (!commentsByDay.containsKey(day)) {
                            commentsByDay[day] = [];
                          }
                          commentsByDay[day]!.add(cleanedComment);
                        }
                      }

                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$restaurant', style: TextStyle(fontSize: 35)),
                            SizedBox(height: 10),
                            Text('Likes: ${feedback.likes ?? 0}', style: TextStyle(fontSize: 25, color: Colors.green)),
                            Text('Dislikes: ${feedback.dislikes ?? 0}', style: TextStyle(fontSize: 25, color: Colors.red)),
                            SizedBox(height: 30),
                            Text('Comments:', style: TextStyle(fontSize: 25)),
                            SizedBox(height: 20),
                            commentsByDay.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: commentsByDay.entries.map((entry) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Day ${entry.key}:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        ...entry.value.map((comment) => Text("> "+"$comment", style: TextStyle(fontSize: 20))).toList(),
                                        SizedBox(height: 20),
                                      ],
                                    );
                                  }).toList(),
                                )
                              : Text('No comments for now.', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
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
                onPressed: () {},
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