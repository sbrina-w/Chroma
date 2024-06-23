import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analyzer.dart';
import 'take_photo.dart';
import 'user_palette.dart';
import 'dart:async';

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
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Poppins',
          bodyColor: Color(0xFF6772AB),
          displayColor: Color(0xFF6772AB),
        ),
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
                children: [
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
                icon: Icons.palette,
                text: 'Add or Edit Your Colours',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPalettePage(),
                    ),
                  );
                },
              ),
              CustomButton(
                icon: Icons.add_photo_alternate,
                text: 'Upload a Reference Photo',
                onPressed: _pickImage,
              ),
              CustomButton(
                icon: Icons.add_a_photo,
                text: 'Take a Reference Photo',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TakePhotoPage()),
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
  final IconData icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6772AB),
          minimumSize: const Size(250, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align icon and text to start
          children: [
            const SizedBox(width: 15),
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
