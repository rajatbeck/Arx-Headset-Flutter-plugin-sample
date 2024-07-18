import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:arx_headset_plugin/arx_headset_plugin.dart';


enum UiState {
  ArxHeadsetConnected,
  DeviceDisconnected,
  DeviceError,
  PermissionNotGiven,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UiState _uiState = UiState.DeviceDisconnected;
  String _errorMessage = '';
  final _arxHeadsetPlugin = ArxHeadsetPlugin();
  String _imuData = '';
  final StreamController<ui.Image> _imageController = StreamController<ui.Image>();
  Stream<ui.Image> get _imageStream => _imageController.stream;

  @override
  void dispose() {
    _imageController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _uiState = UiState.DeviceDisconnected; // Initialize with a default state
    _errorMessage = '';
    _imuData = '';
    initService();
  }

  void initService() {
    try {
      _arxHeadsetPlugin.getPermissionDeniedEvent().listen((event) {
        setState(() {
          _uiState = UiState.PermissionNotGiven;
        });
      });
      _arxHeadsetPlugin.getUpdateViaMessage().listen((event) {
        _showToast(event);
      });
      _arxHeadsetPlugin.getListOfResolutions().listen((event) {
        setState(() {
          _uiState = UiState.ArxHeadsetConnected;
        });
      });
      _arxHeadsetPlugin.getBitmapStream().listen((dynamic event) async {
        final Uint8List imageData = Uint8List.fromList(event);
        final ui.Image image = await decodeImage(imageData);
        _imageController.add(image);
      });
      _arxHeadsetPlugin.getImuDataStream().listen((event) {
        setState(() {
          _imuData = event;
        });
      });
      _arxHeadsetPlugin.disconnectedStream().listen((event) {
        setState(() {
          _uiState = UiState.DeviceDisconnected;
        });
      });
      _arxHeadsetPlugin.startArxHeadSet();
    } on PlatformException {}
  }

  Future<ui.Image> decodeImage(Uint8List data) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arx Sample App'),
        ),
        body: Center(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case UiState.ArxHeadsetConnected:
        return _buildConnectedView();
      case UiState.DeviceDisconnected:
        return _buildDisconnectedView(
          title: 'Device Disconnected',
          subtitle: 'Plug in the device to start the Arx Headset',
          buttonText: 'Start Arx Headset',
          buttonAction: () {
            _arxHeadsetPlugin.startArxHeadSet();
          },
        );
      case UiState.DeviceError:
        return _buildDisconnectedView(
          title: 'Device Streaming error',
          subtitle: _errorMessage,
          buttonText: 'Restart Service',
          buttonAction: () {
            // Call your method to restart the service
          },
        );
      case UiState.PermissionNotGiven:
        return _buildDisconnectedView(
          title: 'ArxHeadset Permission not given',
          subtitle: 'Press permission button UI to give required permission',
          buttonText: 'Launch Permission UI',
          buttonAction: () {
            _arxHeadsetPlugin.launchPermissionUi();
          },
        );
      default:
        return Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildConnectedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 2 / 1,
                child: StreamBuilder<ui.Image>(
                  stream: _imageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Container(
                        color: Colors.grey,
                        child: Center(child: Text('No Image')),
                      );
                    } else {
                      return CustomPaint(
                        painter: ImagePainter(snapshot.data!),
                        child: Container(),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 24), // Vertical margin
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Column(children: [
                  HeadsetButtonsLayout(),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("$_imuData"))
                ]),
              ), // Added text
              Spacer(), // This pushes the button to the bottom
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _arxHeadsetPlugin.stopArxHeadset();
            },
            child: Text('Stop Arx Headset'),
          ),
        ),
      ],
    );
  }

  Widget HeadsetButtonsLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: <Widget>[
          Spacer(flex: 1),
          Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Image.asset('assets/images/circle_small.png',
                      color: Color(0xff280D78), width: 64, height: 64),
                ),
              ),
              SizedBox(height: 8), // Adjust the spacing between buttons
              Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/circle_small.png',
                    color: Color(0xff280D78),
                    width: 64,
                    height: 64,
                  ),
                ),
              ),
            ],
          ),
          Spacer(flex: 1),
          Container(
            child: Center(
              child: Image.asset('assets/images/square.png',
                  color: Color(0xff280D78), width: 64, height: 64),
            ),
          ),
          Spacer(flex: 1),
          Container(
            child: Center(
              child: Image.asset('assets/images/circle.png',
                  color: Color(0xff280D78), width: 64, height: 64),
            ),
          ),
          Spacer(flex: 1),
          Container(
            child: Center(
              child: Image.asset('assets/images/triangle.png',
                  color: Color(0xff280D78), width: 64, height: 64),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUiState(UiState uiState) {
    setState(() {
      _uiState = uiState;
    });
  }

  void _handleDeviceError(String errorMessage) {
    setState(() {
      _uiState = UiState.DeviceError;
      _errorMessage = errorMessage;
    });
  }

  Widget _buildDisconnectedView(
      {String title = "",
      String subtitle = "",
      String buttonText = "",
      VoidCallback? buttonAction}) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // Add horizontal padding
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                // Button padding
                backgroundColor: Colors.blue.shade900,
                // Background color
                foregroundColor: Colors.white, // Text color
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }


}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image on the canvas
    paintImage(canvas: canvas, rect: Offset.zero & size, image: image);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


