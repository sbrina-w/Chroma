import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analyzer.dart';
import 'take_photo.dart';
import 'dart:convert';
import 'user_palette.dart';
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
                  text: 'Take a Reference Photo',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TakePhotoPage()),
                    );
                  }),
              CustomButton(
                text: 'Upload a Reference Photo',
                onPressed: _pickImage,
              ),
              CustomButton(
                text: 'Add Your Colours',
                onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserPalettePage(),
                        ),
                    );
                },
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
