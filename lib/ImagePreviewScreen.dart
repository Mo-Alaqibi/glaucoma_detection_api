
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  const ImagePreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _loading = false;
  String? _result;
  double? _confidence;

  Future<void> uploadImage() async {
    setState(() {
      _loading = true;
      _result = null;
      _confidence = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.178.241:8000/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', widget.imageFile.path));

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var responseJson = jsonDecode(responseString);

      setState(() {
        _loading = false;
        _result = responseJson['result'];
        _confidence = responseJson.containsKey('confidence')
            ? double.parse(responseJson['confidence'].toString())
            : 0.85;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = 'حدث خطأ في التحليل';
        _confidence = null;
      });
      print('Exception: $e');
    }
  }

  Widget _buildResultWidget() {
    if (_result == null) return Container();

    bool isGlaucoma = _result == 'glaucoma';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: isGlaucoma ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isGlaucoma ? Colors.red : Colors.green,
              width: 1,
            ),
          ),
          child: Text(
            isGlaucoma ? 'تم تشخيص إصابة بالجلوكوما' : 'النتيجة طبيعية',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isGlaucoma ? Colors.red : Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'معلومات التحليل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: _confidence,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  (_confidence ?? 0) > 0.7 ? Colors.green : Colors.orange,
                ),
                minHeight: 15,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('نسبة الدقة:', style: TextStyle(fontSize: 16)),
                  Text(
                    '${((_confidence ?? 0) * 100 - 5).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if ((_confidence ?? 1) < 0.7)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'ملاحظة: النسبة متوسطة، يفضل استشارة طبيب',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('معاينة الصورة وتحليلها'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(widget.imageFile, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _loading ? null : uploadImage,
                icon: const Icon(Icons.analytics),
                label: _loading ? Text('جاري التحليل...') : Text('تحليل الصورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(200, 50),
                ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
              _buildResultWidget(),
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('تحليل صورة أخرى'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
