import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  List<int> _mixingRatios = [];
  int _selectedColorIndex = -1;

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

void _editColor(int index) {
  Color currentColor = _paletteColors[index];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      Color pickedColor = currentColor;
      return AlertDialog(
        title: const Text('Select Color', style: TextStyle(fontFamily: 'Poppins')),
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
            child: Text('Delete', style: TextStyle(fontFamily: 'Poppins')),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _paletteColors.removeAt(index);
                if (_selectedColorIndex == index) {
                  _selectedColorIndex = -1;
                } else if (_selectedColorIndex > index) {
                  _selectedColorIndex--;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _paletteColors[index] = pickedColor;
              });
            },
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
        title: const Text('Select New Color', style: TextStyle(fontFamily: 'Poppins')),
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
            child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Prominent Colours:',
                  style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      _showInfoDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPalette(),
              const SizedBox(height: 40),
              Text('Your Colour Palette:',
              style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              _buildUserPalette(),
              const SizedBox(height: 60),
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
              bool isSelected = index == _selectedColorIndex;
              double circleSize = isSelected ? 40.0 : 50.0;
              double topMargin = isSelected ? 5.0 : 0.0;

              return GestureDetector(
                onTap: () => _handleTapColor(index),
                onLongPress: () => _editColor(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: circleSize,
                  height: circleSize,
                  margin: EdgeInsets.only(top: topMargin, left: 4, right: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _paletteColors[index],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 20.0)
                      : null, // show checkmark only if selected
                ),
              );
            } else {
              return GestureDetector(
                onTap: _addNewColor,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
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
      ? Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(_userPaletteColors.length, (index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _userPaletteColors[index],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                  if (_mixingRatios.isNotEmpty && index < _mixingRatios.length)
                    Text(
                      '${(_mixingRatios[index]).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              );
            }),
          ),
        )
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have not added any colours yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPalettePage(),
                  ),
                );
                if (result != null) {
                  _loadPaletteColors();
                  _buildUserPalette();
                }
              },
              child: Text('Add Color Palette'),
            ),
          ],
        );
}



  void _handleTapColor(int index) async {
    setState(() {
      _selectedColorIndex = index;
    });

    List<String> prominentHexColors = _paletteColors.map((color) {
      return '#${color.value.toRadixString(16).substring(2)}';
    }).toList();

    List<String> userPaletteHexColors = _userPaletteColors.map((color) {
      return '#${color.value.toRadixString(16).substring(2)}';
    }).toList();

    Map<String, dynamic> payload = {
      'available_hex_colors': userPaletteHexColors,
      'target_hex_color': prominentHexColors[index], // target color to find mixing ratios
    };

    final url = 'http://54.84.5.214/calculatemix';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> mixingRatios = data['optimal_mixing_ratios'];

      setState(() {
        _mixingRatios = mixingRatios.map((ratioData) {
          var ratio = ratioData['ratio'];
          return ratio.toInt();
        }).toList().cast<int>();
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

void _showInfoDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Long press a colour to edit it.'),
            SizedBox(height: 10),
            Text('Tap a color to get colour mixing ratios.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

}