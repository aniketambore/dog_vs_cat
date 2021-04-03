// 1. Pick Image
//2. Load Tflite Model
//3. Applying the Loaded Model

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dog vs Cat',
        theme: ThemeData(
            primaryColor: Colors.cyan[400],
            accentColor: Colors.deepOrange[200]),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _image;
  final picker = ImagePicker();

  List _result;
  String _confidence;
  String _name;
  String _index;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        applyingModel(File(pickedFile.path));
      } else {
        print("No image selected");
      }
    });
  }

  loadingModel() async {
    var resultant = await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
    print("After Loading Models $resultant");
  }

  applyingModel(File file) async {
    var recognitions = await Tflite.runModelOnImage(
        path: file.path,
        // required
        imageMean: 0.0,
        // defaults to 117.0
        imageStd: 255.0,
        // defaults to 1.0
        numResults: 2,
        // defaults to 5
        threshold: 0.2,
        // defaults to 0.1
        asynch: true // defaults to true
        );

    setState(() {
      _result = recognitions;
      print("Result is $_result");

      String str = _result[0]["label"];
      print("str is $str");

      _name = str.substring(2);
      _confidence = _result != null
          ? (_result[0]["confidence"] * 100.0).toString().substring(0, 2) + "%"
          : "";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dog vs Cat"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              _result != null
                  ? Text(
                      "Name: $_name , Confidence: $_confidence",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    )
                  : Text(""),
              _image == null
                  ? Text("No image selected.")
                  : Image.file(
                      _image,
                      height: 450,
                    ),
            ],
          ),
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}
