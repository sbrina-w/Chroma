import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'analyzer.dart';

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({super.key});

  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _takenPhoto;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      const CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // photo confirmation dialog
  Future<void> _showPhotoOptionsDialog(XFile photo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Preview Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.file(File(photo.path)), // displaying photo
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _controller.initialize().then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: const Text('Retake'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnalyzerPage(imagePath: photo.path),
                        ),
                      );
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Photo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          width: 80.0,
          height: 80.0,
          child: FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                XFile photo = await _controller.takePicture();
                setState(() {
                  _takenPhoto = photo;
                });
                _showPhotoOptionsDialog(photo);
              } catch (e) {
                print('Error: $e');
              }
            },
            child: const Icon(Icons.photo_camera, size: 40.0),
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF6772AB),
            elevation: 5,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
