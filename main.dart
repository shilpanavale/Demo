import 'dart:io';
import 'package:detect/vision-text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _file;
  List<VisionText> currentLabels = <VisionText>[];

  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child:Text('Drawer Header',
                textAlign: TextAlign.center ,),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_upload),
              title: Text('Upload Invoice'),
              onTap: () {
                // click to capture invoice
                getInvoice();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome !',),
          ],
        ),
      ),
    );
  }
  getInvoice() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      if (file != null) {
        setState(() {
          _file = file;
        });
        try {
          var currentLabels = await detector.detectFromPath(_file?.path);
          setState(() {
            currentLabels = currentLabels;
            // Navigate to VisionTextWidget screen and detect text using mlkit plugin
            Navigator.push(context, MaterialPageRoute(builder: (context) => VisionTextWidget(currentLabels:currentLabels)));
          });
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
  }
