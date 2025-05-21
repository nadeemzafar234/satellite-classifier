import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

void main() {
  runApp(SatelliteClassifierApp());
}

class SatelliteClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satellite Classifier',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  String? _result;
  bool _loading = false;

  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
      uploadImage(_image!);
    }
  }

  Future uploadImage(File imageFile) async {
    setState(() => _loading = true);

    var request = http.MultipartRequest(
      'POST',
        Uri.parse('https://2512-139-135-55-127.ngrok-free.app/predict')
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final decoded = json.decode(respStr);
      setState(() {
        _result = "Class: ${decoded['predicted_class']}\nConfidence: ${(decoded['confidence'] * 100).toStringAsFixed(2)}%";
      });
    } else {
      setState(() {
        _result = "Error: ${response.statusCode}";
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Satellite Classifier')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Satellite Image'),
            ),
            SizedBox(height: 20),
            _loading ? CircularProgressIndicator() : Container(),
            _image != null
                ? Image.file(_image!, height: 200)
                : Text("No image selected"),
            SizedBox(height: 20),
            _result != null
                ? Text(_result!, style: TextStyle(fontSize: 18))
                : Container(),
          ],
        ),
      ),
    );
  }
}
