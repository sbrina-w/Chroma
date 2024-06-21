import 'dart:io';
import 'package:flutter/material.dart';

class AnalyzerPage extends StatelessWidget {
  final String imagePath;

  AnalyzerPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Photo'),
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(File(imagePath))
            : Text('No image selected.'),
      ),
    );
  }
}