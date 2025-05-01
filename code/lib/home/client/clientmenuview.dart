import 'package:flutter/material.dart';
import 'package:es_app/services/database.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

Color client_color = const Color.fromRGBO(163, 163, 67, 1.0);

class MenuPage extends StatefulWidget {
  
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String restaurant = client_restaurant_menu;
  final DatabaseService _databaseService = DatabaseService();
  Meal? meal;
  String mealName = '';
  double price = 0.0;
  int ids = 0;
  String status = '';

  DateTime today = DateTime.now();
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDataFromFirestore();
  }

  Future<void> _getDataFromFirestore() async {
    try {
      final idsValue = await _databaseService.getIdfromRestaurant(restaurant);
      if (mounted) {
        setState(() {
          ids = int.parse(idsValue);
        });
      }
    } catch (error) {
      print('Error fetching data from Firestore: $error');
      // Handle the error as needed
    }
  }
  
  Future<void> _fetchMeal() async {
    try {
      final fetchedMeal = await _databaseService.getMeal(restaurant, today);
      setState(() {
        meal = fetchedMeal;
      });
    } catch (error) {
      print('Error fetching meal: $error');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteQ'),
        backgroundColor:  client_color,
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
        child: Column(
            children: [
              Text('$restaurant Calendar', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container (
                      child: TableCalendar(
                        locale: 'en_US',
                        rowHeight: 60,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        availableGestures: AvailableGestures.all,
                        selectedDayPredicate: (day) => isSameDay(day, today),
                        focusedDay: today, 
                        firstDay: DateTime.utc(2010, 10, 16), 
                        lastDay: DateTime.utc(2030, 3, 14),
                        onDaySelected: _onDaySelected,
                          calendarStyle: CalendarStyle(
                            // Ajuste o tamanho do Container de evento quando clicado
                            selectedDecoration: BoxDecoration(
                              shape: BoxShape.circle, // Formato do Container (neste caso, um círculo)
                              color: Colors.blue, // Cor do Container
                            ),
                          ),
                        )
                    ),
                    //const SizedBox(height: 10),
                    //Text("Selected Day = " + today.toString().split(" ")[0], style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    if (ids != 3) ...[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[200],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            FutureBuilder<Meal>(
                              future: _databaseService.getMeal(restaurant, today),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 10),
                                        Text('Loading meal...'),
                                      ],
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  Meal food = snapshot.data!;
                                  String mealName = food.meal;
                                  double price = food.price;
                                  bool isVegan = food.isVegan;
                                  bool isGlutenFree = food.isGlutenFree; 
                                  
                                  if (mealName == '' && price == 0.0) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No meal available for today.',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            Text("Selected Day = " + today.toString().split(" ")[0], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                      ),
                                      Text("             Meal: " + mealName, style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Price: " + price.toString() + "€", style: TextStyle(fontSize: 15)),
                                          if (mealName != '' && price != 0.0) // Verifica se há uma refeição disponível
                                            Column(
                                              children: [
                                                if (isVegan) 
                                                  Text("Vegan", style: TextStyle(fontSize: 15, color: Colors.green)),
                                                if (isGlutenFree) 
                                                  Text("Gluten-Free", style: TextStyle(fontSize: 15, color: Colors.orange)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    if (ids > 2) ...[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantProductListPage(restaurantId: restaurant, time: today),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('List Products', style: TextStyle(color: Colors.white)),
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: client_color, 
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

class RestaurantProductListPage extends StatefulWidget {
  final String restaurantId;
  final DateTime time;

  RestaurantProductListPage({required this.restaurantId, required this.time});

  @override
  _RestaurantProductListPageState createState() => _RestaurantProductListPageState();
}

class _RestaurantProductListPageState extends State<RestaurantProductListPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await _databaseService.getProducts(widget.restaurantId, widget.time);
      setState(() {
        products = fetchedProducts;
      });
    } catch (error) {
      print('Error fetching products: $error');
      // Tratar o erro conforme necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: products.isEmpty
              ? Center(child: Text('No products available.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        products[index].name,
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${products[index].price.toString()}€',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (products[index].isVegan) 
                            Text(
                              'Vegan',
                              style: TextStyle(fontSize: 14, color: Colors.green),
                            ),
                          if (products[index].isGlutenFree) 
                            Text(
                              'Gluten-Free',
                              style: TextStyle(fontSize: 14, color: Colors.orange),
                            ),
                        ],
                      ),
                    );
                  },
                )
          ),
        ],
      ),
    );
  }
}