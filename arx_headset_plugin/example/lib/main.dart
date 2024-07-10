import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:arx_headset_plugin/arx_headset_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool permissionDenied = false;
  final _arxHeadsetPlugin = ArxHeadsetPlugin();

  @override
  void initState() {
    super.initState();
    initService();
  }

  void initService() {
    try {
      _arxHeadsetPlugin.getPermissionDeniedEvent().listen((event) {
          setState(() {
            permissionDenied = true;
          });
      });
      _arxHeadsetPlugin.initService();
    } on PlatformException {

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _buildBody()
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (permissionDenied) {
      return _buildPermissionDeniedLayout();
    } else {
      return Text('start rendering');
    }
  }

  Widget _buildPermissionDeniedLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'ArxHeadset Permission not given',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text("Press permission button UI to give required permission"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: null,
            child: Text('Launch permission UI'),
          ),
        ],
      ),
    );
  }
}
