import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../theme/app_theme.dart';

class OcrPage extends StatefulWidget {
  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  late ImagePicker imagePicker;
  late TextRecognizer textRecognizer;

  File? image;
  String texteExtrait = '';
  bool chargement = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    textRecognizer = TextRecognizer();
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> choisirImage() async {
    final XFile? fichier = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (fichier == null) return;

    setState(() {
      image = File(fichier.path);
      texteExtrait = '';
      chargement = true;
    });

    final InputImage inputImage = InputImage.fromFilePath(fichier.path);
    final RecognizedText resultat =
        await textRecognizer.processImage(inputImage);

    setState(() {
      texteExtrait =
          resultat.text.isEmpty ? 'Aucun texte trouvé.' : resultat.text;
      chargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Reconnaissance de Texte'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Zone image ──────────────────────────────────────
          Container(
            margin: EdgeInsets.all(20),
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary),
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Aucune image sélectionnée',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),

          // ── Bouton choisir image ────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                choisirImage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Choisir une image',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          SizedBox(height: 20),

          // ── Chargement ──────────────────────────────────────
          if (chargement)
            Column(
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 10),
                Text(
                  'Analyse en cours...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

          // ── Résultat texte ──────────────────────────────────
          if (!chargement && texteExtrait.isNotEmpty)
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Texte extrait :',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        texteExtrait,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 24, 23, 23),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
