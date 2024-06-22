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
      maximumColorCount: 30,
    );

    // selecting up to 10 distinct colours
    List<Color> filteredColors = _filterColors(paletteGenerator);

    setState(() {
      _paletteColors = filteredColors;
    });
  }

  List<Color> _filterColors(PaletteGenerator paletteGenerator) {
    List<Color> colors = [];

    // sorting colours by saturation and luminance
    List<Color> sortedColors = paletteGenerator.colors.toList()
      ..sort((a, b) {
        double aSaturation = _colorSaturation(a);
        double bSaturation = _colorSaturation(b);
        if (aSaturation != bSaturation) {
          return bSaturation.compareTo(aSaturation); // Sort by saturation descending
        } else {
          return _colorLuminance(b).compareTo(_colorLuminance(a)); // Sort by luminance ascending
        }
      });

    // Select up to 10 distinct colors
    for (Color color in sortedColors) {
      if (colors.length >= 10) break; // Limit the palette size to 10 colors

      bool shouldAdd = true;
      for (Color addedColor in colors) {
        // Adjust similarity threshold as per your requirement
        if (_colorSimilarity(color, addedColor) < 30) {
          shouldAdd = false;
          break;
        }
      }
      if (shouldAdd) {
        colors.add(color);
      }
    }

    return colors;
  }

  double _colorSaturation(Color color) {
    return HSVColor.fromColor(color).saturation;
  }

  double _colorLuminance(Color color) {
    return color.computeLuminance();
  }

  // calculating colour similarity
  double _colorSimilarity(Color color1, Color color2) {
    // using rgb difference
    int rDiff = (color1.red - color2.red).abs();
    int gDiff = (color1.green - color2.green).abs();
    int bDiff = (color1.blue - color2.blue).abs();
    return (rDiff + gDiff + bDiff) / 3.0; // average difference
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
