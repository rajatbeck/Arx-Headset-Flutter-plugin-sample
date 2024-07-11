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

  @override
  void initState() {
    super.initState();
    _uiState = UiState.DeviceDisconnected; // Initialize with a default state
    _errorMessage = '';
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
      _arxHeadsetPlugin.initService();
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
        return _buildDisconnectedView(
          title: 'Device Disconnected',
          subtitle: 'Plug in the device to start the Arx Headset',
          buttonText: 'Start Arx Headset',
          buttonAction: () {
            // Call your method to start the Arx Headset service
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Arx Headset Connected'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: buttonAction,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

}
