import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPalettePage extends StatefulWidget {
  @override
  _UserPalettePageState createState() => _UserPalettePageState();
}

class _UserPalettePageState extends State<UserPalettePage> {
  List<Color> _paletteColors = [];

  @override
  void initState() {
    super.initState();
    _loadPalette();
  }

  Future<void> _loadPalette() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? colorStrings = prefs.getStringList('paletteColors');
    if (colorStrings != null) {
      setState(() {
        _paletteColors = colorStrings.map((color) => Color(int.parse(color))).toList();
      });
    }
  }

  Future<void> _savePalette() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> colorStrings = _paletteColors.map((color) => color.value.toString()).toList();
    await prefs.setStringList('paletteColors', colorStrings);
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Image picked: ${image.path}');
      await _uploadImage(image.path);
    } else {
      print('No image selected');
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    final uri = Uri.parse('http://54.84.5.214/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      final List<String> colors = List<String>.from(data['colors']);
      print('Colors received: $colors');
      _showColorPalette(colors);
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  void _showColorPalette(List<String> colors) {
    List<Color> parsedColors = colors.map((color) {
      return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Extracted Colors"),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: parsedColors.map((color) {
              return GestureDetector(
                onTap: () {
                },
                child: Container(
                  width: 50,
                  height: 50,
                  color: color,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            }).toList(),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add to Palette'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors.addAll(parsedColors);
                  _savePalette();
                });
              },
            ),
          ],
        );
      },
    );
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
                  _savePalette();
                });
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors.removeAt(index);
                  _savePalette();
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
    Color pickedColor = Colors.white;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add to Palette'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _paletteColors.add(pickedColor);
                  _savePalette();
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
        title: Text('Your Palette'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEDDF5), Color(0xFFF1EDEB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              CustomButton(
                text: 'Upload Swatches',
                onPressed: _pickAndUploadImage,
              ),
              const SizedBox(height: 20),
              Text('Your Palette:'),
              const SizedBox(height: 10),
              _buildPalette(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPalette() {
    return Wrap(
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
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({Key? key, required this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A4A9E),
          minimumSize: const Size(300, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
