import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../theme/app_theme.dart';

class TranslatePage extends StatefulWidget {
  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  // ── Variables ───────────────────────────────────────────────
  late TextEditingController txtTexte;
  late OnDeviceTranslator translator;

  String texteTraduit = '';
  bool chargement = false;

  // Langue source et langue cible
  TranslateLanguage langueSource = TranslateLanguage.french;
  TranslateLanguage langueCible = TranslateLanguage.english;

  // Liste des langues disponibles
  final List<Map<String, dynamic>> langues = [
    {'nom': 'Français', 'code': TranslateLanguage.french},
    {'nom': 'Anglais', 'code': TranslateLanguage.english},
    {'nom': 'Arabe', 'code': TranslateLanguage.arabic},
    {'nom': 'Espagnol', 'code': TranslateLanguage.spanish},
    {'nom': 'Allemand', 'code': TranslateLanguage.german},
  ];

  // ── initState ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    txtTexte = TextEditingController();
    _creerTraducteur();
  }

  // ── Créer le traducteur ML Kit ──────────────────────────────
  void _creerTraducteur() {
    translator = OnDeviceTranslator(
      sourceLanguage: langueSource,
      targetLanguage: langueCible,
    );
  }

  // ── dispose ─────────────────────────────────────────────────
  @override
  void dispose() {
    txtTexte.dispose();
    translator.close();
    super.dispose();
  }

  // ── Fonction : traduire le texte ────────────────────────────
  Future<void> _traduire() async {
    // Si le champ est vide, on arrête
    if (txtTexte.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entrez un texte à traduire')),
      );
      return;
    }

    setState(() {
      chargement = true;
      texteTraduit = '';
    });

    // ML Kit traduit le texte
    final String resultat = await translator.translateText(txtTexte.text);

    setState(() {
      texteTraduit = resultat;
      chargement = false;
    });
  }

  // ── Fonction : changer les langues ──────────────────────────
  void _changerLangues() {
    setState(() {
      // Inverser source et cible
      TranslateLanguage temp = langueSource;
      langueSource = langueCible;
      langueCible = temp;
    });
    // Recréer le traducteur avec les nouvelles langues
    translator.close();
    _creerTraducteur();
  }

  // ── Interface ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Traduction'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sélecteur de langues ────────────────────────
            Row(
              children: [
                // Langue source
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TranslateLanguage>(
                        value: langueSource,
                        dropdownColor: AppTheme.surface,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 88, 87, 87)),
                        items: langues.map((langue) {
                          return DropdownMenuItem<TranslateLanguage>(
                            value: langue['code'],
                            child: Text(langue['nom']),
                          );
                        }).toList(),
                        onChanged: (valeur) {
                          setState(() {
                            langueSource = valeur!;
                          });
                          translator.close();
                          _creerTraducteur();
                        },
                      ),
                    ),
                  ),
                ),

                // Bouton inverser
                IconButton(
                  onPressed: () {
                    _changerLangues();
                  },
                  icon: Icon(
                    Icons.swap_horiz,
                    color: AppTheme.secondary,
                    size: 30,
                  ),
                ),

                // Langue cible
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TranslateLanguage>(
                        value: langueCible,
                        dropdownColor: AppTheme.surface,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 88, 87, 87)),
                        items: langues.map((langue) {
                          return DropdownMenuItem<TranslateLanguage>(
                            value: langue['code'],
                            child: Text(langue['nom']),
                          );
                        }).toList(),
                        onChanged: (valeur) {
                          setState(() {
                            langueCible = valeur!;
                          });
                          translator.close();
                          _creerTraducteur();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // ── Champ texte à traduire ──────────────────────
            Text(
              'Texte à traduire :',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: txtTexte,
              maxLines: 5,
              style: TextStyle(color: const Color.fromARGB(255, 8, 8, 8)),
              decoration: InputDecoration(
                hintText: 'Entrez votre texte ici...',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 132, 132, 132)),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.secondary.withOpacity(0.4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.secondary.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondary),
                ),
              ),
            ),

            SizedBox(height: 16),

            // ── Bouton traduire ─────────────────────────────
            ElevatedButton(
              onPressed: () {
                _traduire();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.black,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Traduire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ── Spinner chargement ──────────────────────────
            if (chargement)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.secondary),
                    SizedBox(height: 10),
                    Text(
                      'Traduction en cours...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // ── Résultat traduction ─────────────────────────
            if (!chargement && texteTraduit.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résultat :',
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.4)),
                    ),
                    child: Text(
                      texteTraduit,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 16, 16, 16),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
