import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class ExpirationDateRecognizer extends StatefulWidget {
  @override
  _ExpirationDateRecognizerState createState() => _ExpirationDateRecognizerState();
}

class _ExpirationDateRecognizerState extends State<ExpirationDateRecognizer> {
  File? _image;
  String _recognizedText = '';

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
    });

    await _recognizeText(File(image.path));
  }

  Future<void> _recognizeText(File image) async {
    TextRecognizer? textRecognizer;

    try {
      final inputImage = InputImage.fromFile(image);
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text;

      setState(() {
        _recognizedText = extractedText;
      });
    } catch (e) {
      print("Error al reconocer texto: $e");
    } finally {
      if (textRecognizer != null) {
        await textRecognizer.close();
      }
    }
  }

  List<String> _extractDates(String text) {
    RegExp datePattern = RegExp(
      r'\b(\d{2})[-/.](\d{2})[-/.](\d{4})\b' // grupos 1-3: dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy
      r'|\b(\d{2})[-/.](\d{2})[-/.](\d{2})\b' // grupos 4-6: dd/mm/yy, dd-mm-yy, dd.mm.yy
      r'|\b(\d{2})[-/.](\d{2})\b' // grupos 7-8: dd/mm, dd-mm, dd.mm
      r'|\b(\d{2})[-/.](\d{4})\b' // grupos 9-10: mm/yyyy, mm-yyyy, m.yyyy
      r'|\b(\d{2})[-/.](JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)\b' // grupos 11-12: dd-MON, dd-MES, etc.
      r'|\b(\d{2})[-/.](JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)[-/.](\d{2})\b' // grupos 13-15: dd-MON-yy, dd-MES-yy, etc.
      r'|\b(\d{2})[-/.](JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)[-/.](\d{4})\b', // grupos 16-18: dd-MON-yyyy, dd-MES-yyyy, etc.
      caseSensitive: false,
    );

    Iterable<Match> matches = datePattern.allMatches(text);
    return matches.map((match) {
      for (int i = 1; i <= 18; i += 3) {
        if (match.group(i) != null && match.group(i+1) != null) {
          if (i + 2 <= 18 && match.group(i+2) != null) {
            // dd-mm-yyyy, dd/mm/yyyy, dd.mm.yyyy, dd-MON-yyyy, dd-MES-yyyy, etc.
            return '${match.group(i)}-${match.group(i+1)}-${match.group(i+2)}';
          } else {
            // dd-mm, dd/mm, dd.mm, dd-MON, dd-MES, etc.
            return '${match.group(i)}-${match.group(i+1)}';
          }
        }
      }
      return 'Fecha no detectada'; // En caso de no encontrar una coincidencia válida.
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Extrae las fechas del texto reconocido.
    List<String> detectedDates = _extractDates(_recognizedText);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reconocimiento de Fecha de Caducidad'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text('No se ha seleccionado ninguna imagen.')
                  : Image.file(_image!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Capturar Imagen'),
              ),
              SizedBox(height: 16),
              Text(
                'Fechas Detectadas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: detectedDates.isEmpty
                      ? [Text('No se detectaron fechas.')]
                      : detectedDates.map((date) => Text(date)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
