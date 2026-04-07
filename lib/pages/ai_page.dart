import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class AiPage extends StatefulWidget {
  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  // ── Variables ───────────────────────────────────────────────
  late TextEditingController txtQuestion;
  late ScrollController scrollController;

  // Historique de la conversation
  List<Map<String, String>> messages = [];
  bool chargement = false;

  // ── initState ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    txtQuestion = TextEditingController();
    scrollController = ScrollController();

    // Message de bienvenue au départ
    messages.add({
      'role': 'assistant',
      'text':
          'Bonjour ! Je suis votre assistant IA. Comment puis-je vous aider ? 😊',
    });
  }

  // ── dispose ─────────────────────────────────────────────────
  @override
  void dispose() {
    txtQuestion.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ── Fonction : envoyer la question à Gemini ─────────────────
  Future<void> _envoyerQuestion() async {
    if (txtQuestion.text.isEmpty) return;

    String question = txtQuestion.text.trim();

    setState(() {
      messages.add({'role': 'user', 'text': question});
      chargement = true;
      txtQuestion.clear();
    });

    _scrollerVersLeBas();

    try {
      // ====================== GROQ ======================
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['GROQ_API_KEY']}', //
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", // Meilleur modèle gratuit actuel
          "messages": [
            {
              "role": "system",
              "content":
                  "Tu es un assistant IA utile, amical et précis. Réponds toujours en français quand la question est en français."
            },
            {"role": "user", "content": question}
          ],
          "temperature": 0.7,
          "max_tokens": 400,
          "top_p": 0.9
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      String reponse = "Je n'ai pas pu générer de réponse.";

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reponse = data['choices'][0]['message']['content'].toString().trim();
      } else {
        reponse = "Erreur ${response.statusCode} : ${response.body}";
      }

      setState(() {
        messages.add({'role': 'assistant', 'text': reponse});
        chargement = false;
      });
    } catch (e) {
      print("ERREUR CATCH: $e");
      setState(() {
        messages.add({
          'role': 'assistant',
          'text':
              'Erreur de connexion.\nVérifie ta connexion internet ou ta clé Groq.'
        });
        chargement = false;
      });
    }

    _scrollerVersLeBas();
  }

  // ── Faire défiler vers le bas ───────────────────────────────
  void _scrollerVersLeBas() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Interface ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Générative AI '),
        backgroundColor: AppTheme.warning,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Liste des messages ──────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool estUtilisateur = messages[index]['role'] == 'user';
                return _buildMessage(
                  messages[index]['text']!,
                  estUtilisateur,
                );
              },
            ),
          ),

          // ── Spinner chargement ──────────────────────────────
          if (chargement)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.warning,
                    strokeWidth: 2,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Gemini réfléchit...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          SizedBox(height: 10),

          // ── Barre de saisie en bas ──────────────────────────
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.warning.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                // Champ texte
                Expanded(
                  child: TextFormField(
                    controller: txtQuestion,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 12, 12, 12)),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onFieldSubmitted: (valeur) {
                      _envoyerQuestion();
                    },
                  ),
                ),
                SizedBox(width: 8),

                // Bouton envoyer
                GestureDetector(
                  onTap: () {
                    _envoyerQuestion();
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget : afficher un message ────────────────────────────
  Widget _buildMessage(String texte, bool estUtilisateur) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: estUtilisateur
            ? MainAxisAlignment.end // message utilisateur → droite
            : MainAxisAlignment.start, // message Gemini → gauche
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Gemini (seulement pour les messages de l'IA)
          if (!estUtilisateur)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.warning,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),

          // Bulle de message
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: estUtilisateur
                    ? AppTheme.warning.withOpacity(0.2)
                    : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft:
                      estUtilisateur ? Radius.circular(16) : Radius.circular(4),
                  bottomRight:
                      estUtilisateur ? Radius.circular(4) : Radius.circular(16),
                ),
                border: Border.all(
                  color: estUtilisateur
                      ? AppTheme.warning.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Text(
                texte,
                style: TextStyle(
                  color: const Color.fromARGB(255, 30, 30, 30),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Avatar utilisateur (seulement pour les messages utilisateur)
          if (estUtilisateur)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
}
