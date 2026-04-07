import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../theme/app_theme.dart';

class FacePage extends StatefulWidget {
  @override
  State<FacePage> createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  // ── Variables ───────────────────────────────────────────────
  late ImagePicker imagePicker;
  late FaceDetector faceDetector;

  File? image;
  List<Face> visages = []; // Liste des visages détectés
  bool chargement = false;

  // ── initState ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();

    // Créer le détecteur avec les options
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Détecter sourire et yeux
        enableLandmarks: true, // Détecter les points du visage
        performanceMode: FaceDetectorMode.accurate, // Mode précis
      ),
    );
  }

  // ── dispose ─────────────────────────────────────────────────
  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  // ── Choisir image depuis galerie ────────────────────────────
  Future<void> choisirImage() async {
    final XFile? fichier = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (fichier == null) return;

    setState(() {
      image = File(fichier.path);
      visages = [];
      chargement = true;
    });

    // Analyser l'image avec ML Kit
    final InputImage inputImage = InputImage.fromFilePath(fichier.path);
    final List<Face> resultat = await faceDetector.processImage(inputImage);

    setState(() {
      visages = resultat;
      chargement = false;
    });
  }

  // ── Convertir probabilité en texte ──────────────────────────
  String _probabiliteEnTexte(double? valeur) {
    if (valeur == null) return 'Inconnu';
    if (valeur > 0.7) return 'Oui ✅';
    if (valeur > 0.3) return 'Peut-être 🤔';
    return 'Non ❌';
  }

  // ── Interface ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Détection de Visage'),
        backgroundColor: AppTheme.accent.withOpacity(0.9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Zone image ──────────────────────────────────
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
              ),
              child: image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face, size: 60, color: Colors.grey),
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

            SizedBox(height: 16),

            // ── Bouton choisir image ────────────────────────
            ElevatedButton(
              onPressed: () {
                choisirImage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
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

            SizedBox(height: 20),

            // ── Spinner chargement ──────────────────────────
            if (chargement)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.accent),
                    SizedBox(height: 10),
                    Text(
                      'Analyse en cours...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // ── Résultat : aucun visage ─────────────────────
            if (!chargement && image != null && visages.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Text(
                  '❌ Aucun visage détecté dans cette image.',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── Résultat : visages détectés ─────────────────
            if (!chargement && visages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de visages
                  Text(
                    '${visages.length} visage(s) détecté(s) 🎉',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Afficher les infos de chaque visage
                  for (int i = 0; i < visages.length; i++)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.accent.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre visage numéro
                          Text(
                            'Visage ${i + 1}',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Divider(color: Colors.grey.withOpacity(0.3)),
                          SizedBox(height: 8),

                          // Sourire
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '😊 Sourire',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 48, 47, 47)),
                              ),
                              Text(
                                _probabiliteEnTexte(
                                    visages[i].smilingProbability),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Oeil gauche ouvert
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '👁️ Oeil gauche ouvert',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 48, 47, 47)),
                              ),
                              Text(
                                _probabiliteEnTexte(
                                    visages[i].leftEyeOpenProbability),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Oeil droit ouvert
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '👁️ Oeil droit ouvert',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 48, 47, 47)),
                              ),
                              Text(
                                _probabiliteEnTexte(
                                    visages[i].rightEyeOpenProbability),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Rotation de la tête
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🔄 Rotation tête',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 48, 47, 47)),
                              ),
                              Text(
                                '${visages[i].headEulerAngleY?.toStringAsFixed(1)}°',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Taille du visage
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📐 Taille du visage',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 48, 47, 47)),
                              ),
                              Text(
                                '${visages[i].boundingBox.width.toStringAsFixed(0)} x ${visages[i].boundingBox.height.toStringAsFixed(0)} px',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
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
