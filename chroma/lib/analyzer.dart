import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class AnalyzerPage extends StatefulWidget {
  final String imagePath;

  AnalyzerPage({required this.imagePath});

  @override
  _AnalyzerPageState createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  List<Color> _paletteColors = [];

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Future<void> _extractPalette() async {
    final File imageFile = File(widget.imagePath);
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile),
      size: Size(200, 200),
      maximumColorCount: 10,
    );

    setState(() {
      _paletteColors = paletteGenerator.colors.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.imagePath.isNotEmpty
                ? Image.file(File(widget.imagePath))
                : Text('No image selected.'),
            const SizedBox(height: 20),
            Text('Prominent Colors:'),
            const SizedBox(height: 10),
            _buildPalette(),
          ],
        ),
      ),
    );
  }

  Widget _buildPalette() {
    return _paletteColors.isNotEmpty
        ? Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: _paletteColors
                .map((color) => Container(
                      width: 50,
                      height: 50,
                      color: color,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ))
                .toList(),
          )
        : CircularProgressIndicator();
  }
}