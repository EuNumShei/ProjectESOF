import 'package:es_app/home/client/clientmenuview.dart';
import 'package:es_app/home/cook/cookmenuview.dart';
import 'package:es_app/home/client/profile.dart';
import 'package:es_app/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home/client/feedback.dart';
import 'home/client/home.dart';
import 'home/index.dart';
import 'home/cook/cookstatistics.dart';
import 'home/client/waitingTimes.dart';
import 'models/user.dart';
import 'services/auth.dart';
import 'home/cook/cookmenu.dart';
import 'home/cook/cookprofile.dart';
import 'home/cook/cookwaitingtimes.dart';
import 'home/client/clientstartmenu.dart';
import 'home/cook/cookfeedback.dart';
import 'home/cook/cookstartmenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCltfTTNJF4EthmSjHDwlhxzHK3CjJj5YY",
      appId: "1:88914635546:android:09dd71ab186f882fae5aa3",
      messagingSenderId: "88914635546",
      projectId: "biteq-575c1",
      storageBucket: "biteq-575c1.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
      value: AuthService().user,
      initialData: MyUser(uid: null),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/index',
        routes: {
          '/index': (context) => const IndexPage(),
          '/wrapper': (context) => Wrapper(),
          '/profile': (context) => ProfilePage(),
          '/feedback': (context) => const FeedbackPage(),
          '/waitingtimes': (context) => const WaitingTimesPage(),
          '/home': (context) => const RestaurantSelectionPage(),
          '/cookmenu': (context) => const CookMenuPage(),
          '/cookprofile': (context) => CookProfilePage(),
          '/cookstatistics': (context) => const CookStatisticsPage(),
          '/cookwaitingtimes': (context) => const CookWaitingTimesPage(),
          '/clientstartmenu' :(context) => const StartClientMenuPage(),
          '/cookstartmenu' :(context) => const StartCookMenuPage(),
          '/cookfeedback': (context) => const CookFeedbackPage(),
          '/clientmenuview': (context) => const MenuPage(),
          '/cookmenuview' :(context) => const CookMenuViewPage(),
        },
      ),
    );
  }
}
