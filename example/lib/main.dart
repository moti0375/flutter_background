import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_example/background_callback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground.instance.registerBackgroundCallback(appBackgroundCallback);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(),
        ),
      ),
    );
  }
}
