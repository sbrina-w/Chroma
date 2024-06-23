import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_palette.dart';

class AnalyzerPage extends StatefulWidget {
  final String imagePath;

  AnalyzerPage({required this.imagePath});

  @override
  _AnalyzerPageState createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  List<Color> _paletteColors = [];
  List<Color> _userPaletteColors = [];

  @override
  void initState() {
    super.initState();
    _extractPalette();
    _loadPaletteColors();
  }

  Future<void> _extractPalette() async {
    final File imageFile = File(widget.imagePath);

    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile),
      size: Size(200, 200),
      maximumColorCount: 30,
    );

    List<Color> filteredColors = _filterColors(paletteGenerator);

    setState(() {
      _paletteColors = filteredColors;
    });
  }

  Future<void> _loadPaletteColors() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String>? colorStrings = prefs.getStringList('paletteColors');
  if (colorStrings != null) {
    setState(() {
      _userPaletteColors = colorStrings.map((color) => Color(int.parse(color))).toList();
    });
  }
}

  List<Color> _filterColors(PaletteGenerator paletteGenerator) {
    List<Color> colors = [];

    List<Color> sortedColors = paletteGenerator.colors.toList()
      ..sort((a, b) {
        double aSaturation = _colorSaturation(a);
        double bSaturation = _colorSaturation(b);
        if (aSaturation != bSaturation) {
          return bSaturation.compareTo(aSaturation);
        } else {
          return _colorLuminance(b).compareTo(_colorLuminance(a));
        }
      });

    for (Color color in sortedColors) {
      if (colors.length >= 10) break;

      bool shouldAdd = true;
      for (Color addedColor in colors) {
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

  double _colorSimilarity(Color color1, Color color2) {
    int rDiff = (color1.red - color2.red).abs();
    int gDiff = (color1.green - color2.green).abs();
    int bDiff = (color1.blue - color2.blue).abs();
    return (rDiff + gDiff + bDiff) / 3.0;
  }

  void _changeColor(int index) {
    Color currentColor = _paletteColors[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickedColor = currentColor;
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2.0),
                topRight: Radius.circular(2.0),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors[index] = pickedColor;
                });
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors.removeAt(index);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addNewColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickedColor = Colors.white;
        return AlertDialog(
          title: const Text('Select New Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2.0),
                topRight: Radius.circular(2.0),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors.add(pickedColor);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculate Colour Mix'),
      ),
      body: SingleChildScrollView(
        child: Center(
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
              const SizedBox(height: 40),
              Text('Your Color Palette:'),
              const SizedBox(height: 10),
              _buildUserPalette(),
              const SizedBox(height: 20),
            ],
          ),
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
            children: List.generate(_paletteColors.length + 1, (index) {
              if (index < _paletteColors.length) {
                return GestureDetector(
                  onTap: () => _changeColor(index),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: _paletteColors[index],
                    margin: EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: _addNewColor,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.add, color: Colors.black),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }
            }),
          )
        : CircularProgressIndicator();
  }

  Widget _buildUserPalette() {
  return _userPaletteColors.isNotEmpty
      ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _userPaletteColors.map((color) {
              return Container(
                width: 50,
                height: 50,
                color: color,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        )
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'You have not added any palettes yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPalettePage(),
                  ),
                );
              },
              child: Text('Add Color Palette'),
            ),
          ],
        );
  }
}