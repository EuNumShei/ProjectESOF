import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_app/services/FBService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPage createState() => _FeedbackPage();
}

class _FeedbackPage extends State<FeedbackPage> {
  late CollectionReference _statisticsRef;
  TextEditingController _feedbackController = TextEditingController();
  Color likeButtonColor = Colors.white; // Initial color for Client button
  Color dislikeButtonColor = Colors.white; // Initial color for Cook button
  String restaurant = '';
  bool like = false;
  bool dislike = false;
  String feedback = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _statisticsRef = FirebaseFirestore.instance.collection('users');
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() {
    _statisticsRef.doc(_auth.currentUser?.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        var data = document.data() as Map<String, dynamic>;

        // Verificar a existência da chave restaurant
        if (data.containsKey('restaurant')) {
          setState(() {
            restaurant = data['restaurant'].toString();
        });
        }
      }
    });
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Feedback:',style: TextStyle(fontSize: 30)),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'According to your last restaurant selection, please give us a vote according to your meal satisfaction',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                )
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20), // Adicionando algum espaço interno ao retângulo
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Adicionando uma borda preta ao redor do retângulo
                  borderRadius: BorderRadius.circular(20), // Arredondando os cantos do retângulo
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: [
                    Text(
                      '$restaurant',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.black,
                      )
                    ),
                    SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          onPressed: () {
                            if (like == false) {
                              setState(() {
                                like = true;
                                likeButtonColor = Colors.grey; // Change color to grey when pressed
                                if (dislike == true) {
                                  dislike = false;
                                  dislikeButtonColor = Colors.white; // Change color to white when pressed
                                }
                              });
                            } else {
                              setState(() {
                                like = false;
                                likeButtonColor = Colors.white; // Change color to white when pressed
                              });
                            }
                            // Add onPressed action for Client button
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors
                                      .grey; // Change color when pressed
                                }
                                return likeButtonColor; // Default color
                              },
                            ),
                          ),
                          iconSize: 24, // Define o tamanho do ícone
                          //color: likeButtonColor, // Define a cor do ícone
                          padding: EdgeInsets.all(16), // Define o espaçamento interno do botão
                          splashRadius: 24, // Define o raio do efeito splash quando pressionado
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down),
                          onPressed: () {
                            if (dislike == false) {
                              setState(() {
                                dislike = true;
                                dislikeButtonColor = Colors.grey; // Change color to grey when pressed
                                if (like == true) {
                                  like = false;
                                  likeButtonColor = Colors.white; // Change color to white when pressed
                                }
                              });
                            } else {
                              setState(() {
                                dislike = false;
                                dislikeButtonColor = Colors.white; // Change color to white when pressed
                              });
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors
                                      .grey; // Change color when pressed
                                }
                                return dislikeButtonColor; // Default color
                              },
                            ),
                          ),
                          iconSize: 24, // Define o tamanho do ícone
                          //color: likeButtonColor, // Define a cor do ícone
                          padding: EdgeInsets.all(16), // Define o espaçamento interno do botão
                          splashRadius: 24, // Define o raio do efeito splash quando pressionado
                        ),
                      ],
                    ),
                  ]
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20), // Adicionando preenchimento horizontal
                child: Text(
                  'If you want to give any additional feedback, feel free to do so in the box below',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20), // Adicionando algum espaço interno ao retângulo
                width: 350,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Adicionando uma borda preta ao redor do retângulo
                  borderRadius: BorderRadius.circular(20), // Arredondando os cantos do retângulo
                  color: Colors.grey[200],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinhar os filhos verticalmente e distribuir espaço entre eles
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10), // Adicionando preenchimento horizontal ao campo de texto
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Give your feedback here...', // Texto de dica dentro do campo de texto
                            //border: OutlineInputBorder(), Adicionando uma borda ao redor do campo de texto
                          ),
                          controller: _feedbackController,
                          maxLines: null, // Permitindo múltiplas linhas de texto no campo de texto
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Verifique se um voto foi selecionado antes de enviar o feedback
                        if (like == false && dislike == false || like == true && dislike == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text('Please select a vote before submitting your feedback'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          String feedbackText = _feedbackController.text;
                          FeedbackService feedbackService = FeedbackService();

                          String feedbackType = (like == true && dislike == false) ? 'Like' : 'Dislike';

                          try {
                            // Chame a função submitFeedback para enviar o feedback e o texto para o Firestore
                            await feedbackService.submitFeedback(feedbackType, feedbackText);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Feedback submitted'),
                                  content: Text('Thank you for your feedback!'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            print(e.toString());
                            // Exiba um diálogo informando que houve um erro ao enviar o feedback
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Failed to submit feedback. Please try again later.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: Text('Submit'), // Texto do botão de submissão
                    ),
                  ],
                ),
              ),
            ]
          )
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(163, 163, 67, 1.0),
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
