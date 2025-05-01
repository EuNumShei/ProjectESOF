import 'package:es_app/services/database.dart'; // Importe o arquivo que contém as funções de banco de dados necessárias
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para enviar o feedback para o Firestore
  Future<void> submitFeedback(String feedback, String comment) async {
    try {
      // Obtenha o ID do usuário atualmente autenticado
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Chame a função do banco de dados para atualizar os dados do usuário com o feedback e o comentário
        await DatabaseService().updateUserDataComment(uid, feedback, comment);
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to submit feedback');
    }
  }
}