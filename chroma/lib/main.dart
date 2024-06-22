import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analyzer.dart';
import 'take_photo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(ChromaApp());
}

class ChromaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chroma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
// method for picking image from device gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // successful image upload
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalyzerPage(imagePath: image.path),
        ),
      );
    }
  }

  //send uploaded image to backend
  Future<void> _uploadImage(String imagePath) async {
    final uri =
        Uri.parse('http://54.84.5.214/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      final List<String> colors = List<String>.from(data['colors']);
      _showColorPalette(colors);
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  //display the extracted color palette, add cap later
  void _showColorPalette(List<String> colors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Extracted Colors"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: colors.map((color) {
              return Container(
                width: 100,
                height: 100,
                color: Color(
                    int.parse(color.substring(1), radix: 16) + 0xFF000000),
                margin: const EdgeInsets.all(4.0),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to pick an image from the gallery and upload it to the backend
  Future<void> _pickAndUploadImage() async {
    // <-- Change 2
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Text(
                'CHROMA',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A9E),
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Personal Colour Assistant',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5A4A9E),
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 50),
              CustomButton(
                  text: 'Take a Photo',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TakePhotoPage()),
                    );
                  }),
              CustomButton(
                text: 'Upload a Photo',
                onPressed: _pickImage,
              ),
              CustomButton(
                text: 'Customize Palette',
                onPressed: _pickAndUploadImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  // widget identification
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
