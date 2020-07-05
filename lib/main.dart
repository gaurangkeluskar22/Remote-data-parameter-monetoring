import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:testapp/screens/HomePage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  // Register your license here
  SyncfusionLicense.registerLicense('');
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RDPM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
