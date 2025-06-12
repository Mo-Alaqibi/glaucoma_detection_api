import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glaucoma_detaction_fainal/ImagePreviewScreen.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(GlaucomaApp());
}

class GlaucomaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          debugShowCheckedModeBanner: false,

      title: 'كشف الجلوكوما',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Tajawal',
      ),
      home: GlaucomaHomePage(),
    );
  }
}

class GlaucomaHomePage extends StatefulWidget {
  @override
  _GlaucomaHomePageState createState() => _GlaucomaHomePageState();
}

class _GlaucomaHomePageState extends State<GlaucomaHomePage> {
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(imageFile: File(pickedFile.path)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('كشف الجلوكوما'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.visibility, size: 100, color: Colors.blue),
              const SizedBox(height: 10),
              const Text(
                "GlaucoScan",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 90),
              Container(
                width: 300,
                height: 200,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text("Scan Eye", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text("Upload Image", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
