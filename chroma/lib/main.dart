import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analyzer.dart';
import 'take_photo.dart';
import 'user_palette.dart';
import 'dart:async';

const IconData add_a_photo = IconData(0xe048, fontFamily: 'MaterialIcons');
const IconData add_photo_alternate = IconData(0xe057, fontFamily: 'MaterialIcons');
const IconData palette = IconData(0xe46b, fontFamily: 'MaterialIcons');

void main() {
  runApp(const ChromaApp());
}

class ChromaApp extends StatelessWidget {
  const ChromaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chroma',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Timer timer;
  late List<Color> colors;
  int currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    colors = [
      const Color(0xFFEBE7D8),
      const Color(0xFFE6D2DD),
      const Color(0xFFEFE9D3),
      const Color(0xFF7983B8),
      Color.fromARGB(255, 130, 161, 196),
      const Color(0xFFD2BBE2),
      Color.fromARGB(255, 204, 163, 186),
      
    ];
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentColorIndex = (currentColorIndex + 1) % colors.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

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
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[currentColorIndex], colors[(currentColorIndex + 1) % colors.length]],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'CHROMA',
                style: TextStyle(
                  fontSize: 70,
                  color: Color(0xFF515D97),
                  fontFamily: 'Bright DEMO',
                ),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Text(
                    'Your Personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF515D97),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Colour Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF515D97),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
  const CustomButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6772AB),
          minimumSize: const Size(250, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
