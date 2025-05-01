import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_app/services/database.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CookMenuPage extends StatefulWidget {
  const CookMenuPage({Key? key}) : super(key: key);

  @override
  _CookMenuPageState createState() => _CookMenuPageState();
}

class _CookMenuPageState extends State<CookMenuPage> {
  String restaurant = '';
  late CollectionReference _statisticsRef;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();
  Meal? meal;
  String mealName = '';
  double price = 0.0;
  int ids = 0;

  DateTime today = DateTime.now();
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

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
              ids = int.parse(idsValue);
            });
          }
        }
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

  Future<void> _removeMeal() async {
    try {
      await _databaseService.removeMeal(restaurant, today);
      // Exibir um diálogo informando que o produto foi removido com sucesso
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Product removed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error removing product: $error');
      // Tratar o erro conforme necessário
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
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantAddMealPage(
                                        restaurantId: restaurant,
                                        time: today,
                                        onMealUpdated: _fetchMeal, // Passa a função _fetchMeal como retorno de chamada
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text('Update meal', style: TextStyle(color: Colors.white)),
                              ),
                            ),
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
                                                if (isVegan) // Check if meal is vegan
                                                  Text("Vegan", style: TextStyle(fontSize: 15, color: Colors.green)),
                                                if (isGlutenFree) // Check if meal is gluten-free
                                                  Text("Gluten-Free", style: TextStyle(fontSize: 15, color: Colors.orange)),
                                              ],
                                            ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              // Implemente a lógica para apagar a refeição
                                              _removeMeal();
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              },
                            )
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

class RestaurantAddMealPage extends StatefulWidget {
  final String restaurantId;
  final DateTime time;
  final Function() onMealUpdated;

  RestaurantAddMealPage({required this.restaurantId, required this.time, required this.onMealUpdated});

  @override
  _RestaurantAddMealPageState createState() => _RestaurantAddMealPageState();
}

class _RestaurantAddMealPageState extends State<RestaurantAddMealPage> {
  final DatabaseService _databaseService = DatabaseService();
  String mealName = '';
  double price = 0.0;
  bool isVegan = false; 
  bool isGlutenFree = false; 

  Future<void> _addMeal() async {
    try {
      if (mealName.isNotEmpty && price != 0.0) {
        await _databaseService.addMeal(
            widget.restaurantId, widget.time, mealName, price, isVegan, isGlutenFree); // Pass the options to the service method
        Navigator.pop(context); // Go back to the previous page after successful addition
        widget.onMealUpdated(); // Update the meal list on the parent page
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid input.'),
              content: Text('Please enter valid meal name and price.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error adding meal: $error');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add meal'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Meal name'),
              onChanged: (value) {
                setState(() {
                  mealName = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price'),
              onChanged: (value) {
                setState(() {
                  price = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Vegan'), // Label for the Vegan option
              value: isVegan, 
              onChanged: (bool? value) {
                setState(() {
                  isVegan = value ?? false; // Toggle the state of the Vegan option
                });
              },
            ),
            CheckboxListTile(
              title: Text('Gluten-Free'), // Label for the Gluten-Free option
              value: isGlutenFree, 
              onChanged: (bool? value) {
                setState(() {
                  isGlutenFree = value ?? false; // Toggle the state of the Gluten-Free option
                });
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: _addMeal,
            ),
          ],
        ),
      ),
    );
  }
}


class RestaurantAddProductPage extends StatefulWidget {
  final String restaurantId;
  final DateTime time;
  final Function() onProductAdded;

  RestaurantAddProductPage({required this.restaurantId, required this.time, required this.onProductAdded});

  @override
  _RestaurantAddProductPageState createState() => _RestaurantAddProductPageState();
}

class _RestaurantAddProductPageState extends State<RestaurantAddProductPage> {
  final DatabaseService _databaseService = DatabaseService();
  String productName = '';
  double price = 0.0;
  bool isVegan = false;
  bool isGlutenFree = false;

  Future<void> _addProduct() async {
    try {
      if (productName.isNotEmpty && price != 0.0) {
        await _databaseService.addProduct(widget.restaurantId, widget.time, productName, price, isVegan, isGlutenFree);
        
        // Update the local state with the new product
        widget.onProductAdded(); // Call the callback function to update the product list on the parent page

        Navigator.pop(context); // Go back to the previous page after successful addition
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid input.'),
              content: Text('Please enter valid product name and price.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error adding product: $error');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Product name'),
              onChanged: (value) {
                setState(() {
                  productName = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price'),
              onChanged: (value) {
                setState(() {
                  price = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Vegan'),
              value: isVegan,
              onChanged: (bool? value) {
                setState(() {
                  isVegan = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Gluten-Free'),
              value: isGlutenFree,
              onChanged: (bool? value) {
                setState(() {
                  isGlutenFree = value ?? false;
                });
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: _addProduct,
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
      // Handle the error as needed
    }
  }

  Future<void> _removeProduct(String productName) async {
    try {
      await _databaseService.removeProduct(widget.restaurantId, widget.time, productName);
      setState(() {
        products.removeWhere((product) => product.name == productName);
      });
      // Show a dialog informing that the product was removed successfully
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Product removed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error removing product: $error');
      // Handle the error as needed
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeProduct(products[index].name);
                        },
                      ),
                    );
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text('Add new product'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantAddProductPage(
                      restaurantId: widget.restaurantId,
                      time: widget.time,
                      onProductAdded: _fetchProducts, // Fetch products again after adding a new one
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}