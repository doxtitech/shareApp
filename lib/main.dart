import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShareApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ShareApp'),
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
  StreamSubscription _intentDataStreamSubscription;
  String _sharedText = '';
  String _sharedFile = '';
  File testFile;

  TextEditingController _textFieldController = new TextEditingController();
  var te = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value != null) {
        setState(() {
          _sharedFile = '';
          try {
            _sharedFile = value[0].path;
            testFile = new File(_sharedFile);
          } catch (err) {
            //
          }
        });
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value != null) {
        setState(() {
          _sharedFile = '';
          _sharedFile = value[0].path;
          print('start2');
          print(value);
          print('end2');
          te = true;
        });
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        if (value != null) {
          _sharedText = value;
        }
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        if (value != null) {
          _sharedText = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_textFieldController != null) {
      _textFieldController.text = _sharedText;
    }

    Widget sharedTextWidget = _sharedText != null && _sharedText.length != 0
        ? Column(children: [
            Text(
              'Shared Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              height: 250,
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _textFieldController,
                style: new TextStyle(height: 1),
                cursorWidth: 2,
              ),
            ),
          ])
        : Container();
    Widget sharedImageWidget = _sharedFile != null && _sharedFile.length > 0
        ? Container(
            child: Column(
              children: [
                Text(_sharedFile),
                Text(
                  'Shared Image:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                testFile.existsSync()
                    ? Image.memory(
                        Uint8List.fromList(testFile.readAsBytesSync()),
                        alignment: Alignment.center,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      )
                    : Container(),
                // new Image.asset(
                //   _sharedFile,
                //   fit: BoxFit.cover,
                // ),
              ],
            ),
          )
        : Container();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[sharedImageWidget, sharedTextWidget],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _sharedFile = '';
            _sharedText = '';
          });
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
