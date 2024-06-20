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
      r'\b(\d{2})[-/](\d{2})[-/](\d{4})\b' // dd/mm/yyyy o dd-mm-yyyy
      r'|\b(\d{2})[-/](\d{2})[-/](\d{2})\b' // dd/mm/yy o dd-mm-yy
      r'|\b(\d{2})-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)-(\d{2}|\d{4})\b' // dd-MON-yy o dd-MON-yyyy
      r'|\b(\d{2})-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\b' // dd-MON
      r'|\b(\d{2})/(\d{4})\b' // mm/yyyy específicamente para mantener el separador
      r'|\b(\d{2})-(\d{4})\b', // mm-yyyy
      caseSensitive: false,
    );

    Iterable<Match> matches = datePattern.allMatches(text);
    return matches.map((match) {
      if (match.group(1) != null && match.group(2) != null && match.group(3) != null) {
        // dd/mm/yyyy o dd-mm-yyyy
        return '${match.group(1)}-${match.group(2)}-${match.group(3)}';
      } else if (match.group(4) != null && match.group(5) != null && match.group(6) != null) {
        // dd/mm/yy o dd-mm-yy
        return '${match.group(4)}-${match.group(5)}-${match.group(6)}';
      } else if (match.group(7) != null && match.group(8) != null && match.group(9) != null) {
        // dd-MON-yy o dd-MON-yyyy
        return '${match.group(7)}-${match.group(8)}-${match.group(9)}';
      } else if (match.group(10) != null && match.group(11) != null) {
        // dd-MON
        return '${match.group(10)}-${match.group(11)}';
      } else if (match.group(12) != null && match.group(13) != null) {
        // mm/yyyy
        return '${match.group(12)}/${match.group(13)}';
      } else if (match.group(14) != null && match.group(15) != null) {
        // mm-yyyy
        return '${match.group(14)}-${match.group(15)}';
      } else {
        return 'Fecha no detectada';
      }
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
