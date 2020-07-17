import 'dart:async';
import 'dart:io';
import 'package:detect/data_read.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

class VisionTextWidget extends StatefulWidget {
  List<VisionText> currentLabels;

  VisionTextWidget({this.currentLabels});
  @override
  _VisionTextWidgetState createState() => _VisionTextWidgetState();
}

class _VisionTextWidgetState extends State<VisionTextWidget> {
  File _file;
  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentLabels);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
         backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Text Detection'),
        ),
        body: _buildBody(),
      ),
    );
  }
  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildList(widget.currentLabels),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<VisionText> texts) {
    if (texts.length == 0) {
      return Text('Empty');
    }
    return AlertDialog(
      elevation:10 ,
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: ListView.builder(
                  padding: const EdgeInsets.all(1.0),
                  shrinkWrap: true,
                  itemCount: texts.length,
                  itemBuilder: (context, i) {
                    return _buildRow(texts[i].text);
                  }),
            )
          ]
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            // Navigate to DataRead screen and shown text using mlkit plugin
            Navigator.push(context, MaterialPageRoute(builder: (context) => DataRead(currentLabels:widget.currentLabels)));
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Ok'),
        ),
        new FlatButton(
          onPressed: () async {
            try {
              var file =
              await ImagePicker.pickImage(source: ImageSource.gallery);
              if (file != null) {
                setState(() {
                  _file = file;
                });
                try {
                  var currentLabels =
                  await detector.detectFromPath(_file?.path);
                  setState(() {
                    widget.currentLabels = currentLabels;
                  });
                } catch (e) {
                  print("loading");
                  print(e.toString());
                }
              }
            } catch (e) {
              print(e.toString());
            }
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildRow(String text) {
    return ListTile(
      title: Text(
        "Text: ${text}",
      ),
      dense: true,
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    print("original Image Size : ${_originalImageSize}");

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      print("text : ${text.text}, rect : ${text.rect}");
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      //final _rect = Rect.fromLTRB(24.0, 115.0, 75.0, 131.2);
      print("_rect : ${_rect}");
      canvas.drawRect(_rect, paint);
    }

    print("offset : ${offset}");
    print("configuration : ${configuration}");

    final rect = offset & configuration.size;

    print("rect container : ${rect}");

    //canvas.drawRect(rect, paint);
    canvas.restore();
  }
}
