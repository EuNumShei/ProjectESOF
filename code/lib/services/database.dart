import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_app/home/client/home.dart';
import 'package:es_app/services/calendar.dart';

String client_restaurant_menu = "";
String cook_restaurant = "";

class Restaurant {
  String id;
  String name;
  String image;
  // Add other fields as needed

  Restaurant({required this.id, required this.name, required this.image});

  factory Restaurant.fromDocument(DocumentSnapshot doc) {
    return Restaurant(
      id: doc['id'],
      name: doc['name'],
      image: doc['image'],
    );
  }
}

class Meal {
  String meal;
  double price;
  bool isVegan; 
  bool isGlutenFree; 

  Meal({
    required this.meal,
    required this.price,
    required this.isVegan,
    required this.isGlutenFree,
  });

  factory Meal.fromDocument(DocumentSnapshot doc) {
    return Meal(
      meal: doc['meal'],
      price: doc['price'],
      isVegan: doc['isVegan'] ?? false, // Add default value
      isGlutenFree: doc['isGlutenFree'] ?? false, // Add default value
    );
  }
}


class Product {
  String name;
  double price;
  bool isVegan;
  bool isGlutenFree;

  Product({
    required this.name,
    required this.price,
    required this.isVegan,
    required this.isGlutenFree,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      name: doc['name'],
      price: doc['price'],
      isVegan: doc['isVegan'],
      isGlutenFree: doc['isGlutenFree'],
    );
  }
}


class Feedbackk {
  int likes;
  int dislikes;
  List<String> comments;

  Feedbackk({
    required this.likes,
    required this.dislikes,
    required this.comments,
  });
}

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference restaurantCollection =
      FirebaseFirestore.instance.collection('restaurants');

  Future<void> updateUserData(
      String email, String password, String status, String restaurant) async {
    return await userCollection.doc(uid).set({
      'email': email,
      'password': password,
      'status': status,
      'restaurant': restaurant,
    });
  }

  Future<String> getUserStatus(String? uid) async {
    final DocumentSnapshot document = await userCollection.doc(uid).get();
    if (document.exists) {
      Map<String, dynamic>? userData = document.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('status')) {
        return userData['status'] as String;
      }
    }
    return '';
  }

  Future<String> getIdfromRestaurant(String restaurant) async {
    for (int i = 1; i < 5; i++) {
      String idr = i.toString();
      final DocumentSnapshot document = await restaurantCollection.doc(idr).get();
      if (document.exists) {
        Map<String, dynamic>? restaurantData = document.data() as Map<String, dynamic>?;
        if (restaurantData != null && restaurantData.containsKey('name')) {
          String name = restaurantData['name'] as String;
          if (name == restaurant) {
            return idr;
          }
        }
      }
    }
    return '';
  }

  Future<void> updateUserRestaurant(String uid, String restaurant) async {
    await userCollection.doc(uid).update({
      'restaurant': restaurant,
    });
    String idr = await getIdfromRestaurant(restaurant);
    final DocumentSnapshot document = await restaurantCollection.doc(idr).get();
    if (document.exists) {
      Map<String, dynamic>? restaurantData = document.data() as Map<String, dynamic>?;
      if (restaurantData != null && restaurantData.containsKey('name')) {
        String name = restaurantData['name'] as String;
        int waiting_time = restaurantData['waiting_time'].toInt();
        if (name == restaurant) { //Check if the restaurant was updated
          updateClientsStats(idr);
          await Future.delayed(Duration(seconds: 30)); 
          waiting_time++;
          await restaurantCollection.doc(idr).update({
            'waiting_time': waiting_time,
          });
        }
      }
    }
    await Future.delayed(Duration(seconds: 60)); 
    final DocumentSnapshot document2 = await restaurantCollection.doc(idr).get();
    if (document2.exists) {
      Map<String, dynamic>? restaurantData = document2.data() as Map<String, dynamic>?;
      if (restaurantData != null && restaurantData.containsKey('name')) {
        String name = restaurantData['name'] as String;
        int waiting_time = restaurantData['waiting_time'].toInt();
        if (name == restaurant) { //Check if the restaurant was updated
          if (waiting_time > 0) {
            waiting_time--;
            await restaurantCollection.doc(idr).update({
              'waiting_time': waiting_time,
            });
          }
        }
      }
    }
  }

  Future<void> updateClientsStats(String idr) async {
    String weekday = get_weekday();
    final currentSemester = getSchoolYear();
    final currentMonthWeek = getCurrentMonthWeek();

    String clientsPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/stats/clients_per_day";
    // Referência ao documento
    final clientsDocRef = restaurantCollection.doc(clientsPath);
    
    // Verificar se o documento existe
    final clientsDocSnapshot = await clientsDocRef.get();
    if (clientsDocSnapshot.exists) {
      // Documento existe
      var clientsData = clientsDocSnapshot.data() as Map<String, dynamic>;
      
      // Verificar se a chave weekday está presente nos dados
      if (clientsData.containsKey(weekday)) {
        int clients = clientsData[weekday].toInt();
        clients++;
        await clientsDocRef.set({
          weekday: clients,
        }, SetOptions(merge: true));
      } else {
        await clientsDocRef.set({
          weekday: 1,
        }, SetOptions(merge: true));
      }
    } else {
      // Documento não existe, então crie-o
      await clientsDocRef.set({
        weekday: 1,
      });
    }
  }

  Future<void> updateUserDataComment(String uid, String feedback, String comment) async {
    await userCollection.doc(uid).update({
      'feedback': feedback,
      'comment': comment,
    });
    String weekday = get_weekday();
    final currentSemester = getSchoolYear();
    final currentMonthWeek = getCurrentMonthWeek();

    final DocumentSnapshot document = await userCollection.doc(uid).get();
    if (document.exists) {
      Map<String, dynamic>? userData = document.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('restaurant')) {
        String restaurant = userData['restaurant'] as String;
        String idr = await getIdfromRestaurant(restaurant);
        if (idr != '') {
          String satisfactionPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/stats/satisfaction_per_day";
          
          final satisfactionDocRef = restaurantCollection.doc(satisfactionPath);

          final satisfactionDocSnapshot = await satisfactionDocRef.get();

          if (satisfactionDocSnapshot.exists) {
            var satisfactionData = satisfactionDocSnapshot.data() as Map<String, dynamic>;
            if (satisfactionData.containsKey(weekday)) {
              int satisfaction = satisfactionData[weekday].toInt();
              satisfaction++;
              await satisfactionDocRef.set({
                weekday: satisfaction,
              }, SetOptions(merge: true));
            } else {
              await satisfactionDocRef.set({
                weekday: 1,
              }, SetOptions(merge: true));
            }
          } else {
            await satisfactionDocRef.set({
              weekday: 1,
            });
          }
          String reviewsPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/feedbacks/reviews";
          
          final reviewsDocRef = restaurantCollection.doc(reviewsPath);

          final reviewsDocSnapshot = await reviewsDocRef.get();

          if (feedback == 'Like') {
            if (reviewsDocSnapshot.exists) {
              var reviewsData = reviewsDocSnapshot.data() as Map<String, dynamic>;
              if (reviewsData.containsKey('like')) {
                int reviews = reviewsData['like'].toInt();
                reviews++;
                await restaurantCollection.doc(reviewsPath).update({
                  'like': reviews,
                });
              } else {
                await restaurantCollection.doc(reviewsPath).update({
                  'like': 1,
                });
              }
            } else {
              await restaurantCollection.doc(reviewsPath).set({
                'like': 1,
              });
            }
          } else if (feedback == 'Dislike') {
            if (reviewsDocSnapshot.exists) {
              var reviewsData = reviewsDocSnapshot.data() as Map<String, dynamic>;
              if (reviewsData.containsKey('dislike')) {
                int reviews = reviewsData['dislike'].toInt();
                reviews++;
                await restaurantCollection.doc(reviewsPath).update({
                  'dislike': reviews,
                });
              } else {
                await restaurantCollection.doc(reviewsPath).update({
                  'dislike': 1,
                });
              }
            } else {
              await restaurantCollection.doc(reviewsPath).set({
                'dislike': 1,
              });
            }
          }

          String commentsPath = "$idr/data/${currentSemester.year}/${currentMonthWeek.month}/${currentMonthWeek.weekNumber.firstDay.day}_${currentMonthWeek.weekNumber.lastDay.day} week/feedbacks/comments";

          final commentsDocRef = restaurantCollection.doc(commentsPath);
          
          final commentsDocSnapshot = await commentsDocRef.get();

          DateTime now = DateTime.now();
          int day = now.day;
          String comment_day = comment + " (day: $day)";

          if (commentsDocSnapshot.exists) {
            var commentsData = commentsDocSnapshot.data() as Map<String, dynamic>;
            List<String> comments = commentsData['comments'] != null ? List<String>.from(commentsData['comments']) : [];
            comments.add(comment_day); // Adiciona o novo comentário à lista de comentários
            await restaurantCollection.doc(commentsPath).update({
              'comments': comments,
            });
          } else {
            // Se o documento não existir, cria um novo com a lista de comentários contendo apenas o novo comentário
            await restaurantCollection.doc(commentsPath).set({
              'comments': [comment_day],
            });
          }   
        }
      }
    }
  }

  Future<Feedbackk> getReviewsComments(String ids) async {
    DateTime time = DateTime.now();
    int year = time.year;
    int month = time.month;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((time.day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String basePath = "$ids/data/$year/$monthName/${weekrange.firstDay.day}_${weekrange.lastDay.day} week";
    String reviewsPath = "$basePath/feedbacks/reviews";
    String commentsPath = "$basePath/feedbacks/comments";

    final reviewsDocRef = restaurantCollection.doc(reviewsPath);
    final commentsDocRef = restaurantCollection.doc(commentsPath);

    final reviewsSnapshot = await reviewsDocRef.get();
    final commentsSnapshot = await commentsDocRef.get();

    if (reviewsSnapshot.exists && commentsSnapshot.exists) {

      int likes = 0;
      int dislikes = 0;
      List<String> comments = [];

      Map<String, dynamic>? reviewsData = reviewsSnapshot.data() as Map<String, dynamic>?;
      if (reviewsData != null && reviewsData.containsKey('like') && reviewsData.containsKey('dislike')) {
        likes = reviewsData['like'].toInt();
        dislikes = reviewsData['dislike'].toInt();
      }

      Map<String, dynamic>? commentsData = commentsSnapshot.data() as Map<String, dynamic>?;
      if (commentsData != null && commentsData.containsKey('comments')) {
        comments = List<String>.from(commentsData['comments'] ?? []);
      }
      return Feedbackk(likes: likes, dislikes: dislikes, comments: comments);
    
    } else {
      return Feedbackk(likes: 0, dislikes: 0, comments: []);
    }
  }

  Future<void> updateRestaurantData(String id, String name, String image) async {
    return await restaurantCollection.doc(id).update({
      'name': name,
      'image': image,
    });
  }

  Future<void> addMeal(String restaurant, DateTime time, String meal, double price, bool isVegan, bool isGlutenFree) async {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);
    
    if (restaurantId < 3 || restaurantId == 4) {
      String mealsPath = "$ids/data/${year}/${monthName}/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/meals/${day}";
      
      final mealsDocRef = restaurantCollection.doc(mealsPath);

      await mealsDocRef.set({
        'meal': meal,
        'price': price,
        'isVegan': isVegan, 
        'isGlutenFree': isGlutenFree, 
      });
    }
  }

  Future<void> removeMeal(String restaurant, DateTime time) async {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);

    if (restaurantId < 3 || restaurantId == 4) {
      String mealsPath = "$ids/data/${year}/${monthName}/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/meals/${day}";
      
      final mealsDocRef = restaurantCollection.doc(mealsPath);

      //final mealsDocSnapshot = await mealsDocRef.get();

      //var mealsData = mealsDocSnapshot.data() as Map<String, dynamic>?;
      await mealsDocRef.delete();
    }
  }

  Future<void> addProduct(String restaurant, DateTime time, String product, double price, bool isVegan, bool isGlutenFree) async {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);

    if (restaurantId > 2) {
      String productsPath = "$ids/data/$year/$monthName/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/products/$day";
      
      final productsDocRef = restaurantCollection.doc(productsPath);

      final productsDocSnapshot = await productsDocRef.get();

      var productsData = productsDocSnapshot.data() as Map<String, dynamic>?;
      if (productsData != null && productsData.containsKey('products') && productsData.containsKey('price')) {
        List<String> products = productsData['products'] != null ? List<String>.from(productsData['products']) : [];
        List<double> prices = productsData['price'] != null ? List<double>.from(productsData['price']) : [];
        List<bool> veganStatuses = productsData['isVegan'] != null ? List<bool>.from(productsData['isVegan']) : [];
        List<bool> glutenFreeStatuses = productsData['isGlutenFree'] != null ? List<bool>.from(productsData['isGlutenFree']) : [];
        
        products.add(product);
        prices.add(price);
        veganStatuses.add(isVegan);
        glutenFreeStatuses.add(isGlutenFree);
        
        await productsDocRef.set({
          'products': products,
          'price': prices,
          'isVegan': veganStatuses,
          'isGlutenFree': glutenFreeStatuses,
        });
      } else {
        await productsDocRef.set({
          'products': [product],
          'price': [price],
          'isVegan': [isVegan],
          'isGlutenFree': [isGlutenFree],
        });
      }
    }
}


  Future<void> removeProduct(String restaurant, DateTime time, String productName) async {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);

    if (restaurantId > 2) {
      String productsPath = "$ids/data/$year/$monthName/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/products/$day";
      
      final productsDocRef = restaurantCollection.doc(productsPath);

      final productsDocSnapshot = await productsDocRef.get();

      var productsData = productsDocSnapshot.data() as Map<String, dynamic>?;
      if (productsData != null && productsData.containsKey('products') && productsData.containsKey('price')) {
        List<String> products = List<String>.from(productsData['products']);
        List<double> prices = List<double>.from(productsData['price']);
        List<bool> veganStatuses = List<bool>.from(productsData['isVegan']);
        List<bool> glutenFreeStatuses = List<bool>.from(productsData['isGlutenFree']);

        int indexToRemove = products.indexWhere((product) => product == productName);
        if (indexToRemove != -1) {
          products.removeAt(indexToRemove);
          prices.removeAt(indexToRemove);
          veganStatuses.removeAt(indexToRemove);
          glutenFreeStatuses.removeAt(indexToRemove);
          
          // Atualiza o documento com a lista de produtos sem o produto removido
          await productsDocRef.set({
            'products': products,
            'price': prices,
            'isVegan': veganStatuses,
            'isGlutenFree': glutenFreeStatuses,
          });
        }
      }
    }
  }


  Future<Meal> getMeal(String restaurant, DateTime time) async {
    Meal food = Meal(meal: '', price: 0.0, isVegan: false, isGlutenFree: false); // Initialize with default values
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);

    if (restaurantId < 3 || restaurantId == 4) {
      String mealsPath = "$ids/data/${year}/${monthName}/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/meals/${day}";
      
      final mealsDocRef = restaurantCollection.doc(mealsPath);

      final mealsDocSnapshot = await mealsDocRef.get();

      var mealsData = mealsDocSnapshot.data() as Map<String, dynamic>?;
      if (mealsData != null && mealsData.containsKey('meal')) {
        String meal = mealsData['meal'] as String;
        double price = mealsData['price'].toDouble();
        bool isVegan = mealsData['isVegan'] ?? false; 
        bool isGlutenFree = mealsData['isGlutenFree'] ?? false; 
        food = Meal(meal: meal, price: price, isVegan: isVegan, isGlutenFree: isGlutenFree); // Update with retrieved values
      }
    }
    return food;
  }


  Future<List<Product>> getProducts(String restaurant, DateTime time) async {
    List<Product> productsList = [];
    int year = time.year;
    int month = time.month;
    int day = time.day;
    final startOfMonth = DateTime(year, month, 1);
    final weekNumber = ((day + (startOfMonth.weekday - 1)) / 7).ceil();
    WeekRange weekrange = getWeekRange(weekNumber, month, year);
    String monthName = _getMonthName(month);
    String ids = await getIdfromRestaurant(restaurant);
    int restaurantId = int.parse(ids);

    if (restaurantId > 2) {
      String productsPath = "$ids/data/$year/$monthName/${weekrange.firstDay.day}_${weekrange.lastDay.day} week/products/$day";
      
      final productsDocRef = restaurantCollection.doc(productsPath);

      final productsDocSnapshot = await productsDocRef.get();

      var productsData = productsDocSnapshot.data() as Map<String, dynamic>?;
      if (productsData != null && productsData.containsKey('products') && productsData.containsKey('price')) {
        List<String> products = productsData['products'] != null ? List<String>.from(productsData['products']) : [];
        List<double> prices = productsData['price'] != null ? List<double>.from(productsData['price']) : [];
        List<bool> veganStatuses = productsData['isVegan'] != null ? List<bool>.from(productsData['isVegan']) : [];
        List<bool> glutenFreeStatuses = productsData['isGlutenFree'] != null ? List<bool>.from(productsData['isGlutenFree']) : [];
        
        for (int i = 0; i < products.length; i++) {
          productsList.add(Product(
            name: products[i],
            price: prices[i],
            isVegan: veganStatuses[i],
            isGlutenFree: glutenFreeStatuses[i],
          ));
        }
      }
    }
    return productsList;
  }


  String _getMonthName(int monthNumber) {
    final monthNames = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    return monthNames[monthNumber - 1];
  }

}
