
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
  Uint8List _imageData = Uint8List(0);
  String _imuData = '';

  @override
  void initState() {
    super.initState();
    _uiState = UiState.DeviceDisconnected; // Initialize with a default state
    _errorMessage = '';
    _imageData = Uint8List(0); // Initialize with an empty byte array
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
      _arxHeadsetPlugin.getListOfResolutions().listen((event){
        setState(() {
          _uiState = UiState.ArxHeadsetConnected;
        });
      });
      _arxHeadsetPlugin.getBitmapStream().listen((dynamic event){
        setState(() {
          _imageData = Uint8List.fromList(event);
        });
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
    } on PlatformException {

    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Arx Sample App'),
        ),
        body: Center(
          child: _buildBody()
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case UiState.ArxHeadsetConnected:
        return _buildConnectedView();
      case UiState.DeviceDisconnected:
        return
          _buildDisconnectedView(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 1,
            child: _imageData.isNotEmpty
                ? Image.memory(
                    _imageData,
                    width: 200,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
              color: Colors.grey,
              child: Center(child: Text('No Image')),
            ),
          ),
          SizedBox(height: 24), // Vertical margin
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(children: [
              HeadsetButtonsLayout(),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("$_imuData"))
            ]),
          ), // Added text
          SizedBox(height: 24), // Vertical margin
          ElevatedButton(
            onPressed: () {
              // Call your method to stop the Arx Headset service
            },
            child: Text('Stop Arx Headset'),
          ),
        ],
      ),
    );
  }

  Widget HeadsetButtonsLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(flex: 1),
          Column(
            children: <Widget>[
              Opacity(
                opacity: 0.2,
                child: Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Image.asset('assets/images/circle_small.png'),
                  ),
                ),
              ),
              SizedBox(height: 8), // Adjust the spacing between buttons
              Opacity(
                opacity: 0.2,
                child: Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Image.asset('assets/images/circle_small.png'),
                  ),
                ),
              ),
            ],
          ),
          Spacer(flex: 1),
          Opacity(
            opacity: 0.2,
            child: Container(
              width: 50,
              height: 50,
              child: Center(
                child: Image.asset('assets/images/square.png'),
              ),
            ),
          ),
          Spacer(flex: 1),
          Opacity(
            opacity: 0.2,
            child: Container(
              width: 50,
              height: 50,
              child: Center(
                child: Image.asset('assets/images/circle.png'),
              ),
            ),
          ),
          Spacer(flex: 1),
          Opacity(
            opacity: 0.2,
            child: Container(
              width: 50,
              height: 50,
              child: Center(
                child: Image.asset('assets/images/triangle.png'),
              ),
            ),
          ),
          Spacer(flex: 1),
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

  Widget _buildDisconnectedView({String title="", String subtitle="", String buttonText="", VoidCallback? buttonAction}) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16), // Add horizontal margin
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16), // Add horizontal padding
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
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Button padding
                backgroundColor: Colors.blue.shade900, // Background color
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
