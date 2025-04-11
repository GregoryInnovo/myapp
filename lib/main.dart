import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'open_camera_screen.dart';
import 'open_gallery_screen.dart';
import 'record_audio_screen.dart';

const appGroupId = 'YOUR_GROUP_ID'; // Replace with your App Group ID

const recordAudioAction = "recordAudioAction";
const sectionKey = "section";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId(appGroupId);
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}
Future<void> backgroundCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId(appGroupId);
  final Uri? uri = await HomeWidget.getBackgroundUri();
  if (uri != null) {
    switch (uri.host) {
      case recordAudioAction:
      case openCameraAction:
      case openGalleryAction:
        break;
      default:
        debugPrint("Unrecognized uri in background callback");
    }
  }
}

Future<void> updateHomeWidget() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/image.png');
  if (await file.exists()) {
    await HomeWidget.saveWidgetData<String>(
        'imageUrl', file.uri.toString());
  }
  await HomeWidget.updateWidget(
      name: 'AppWidgetProvider', iOSName: 'AppWidget'); // Change to match widget names
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widget Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    HomeWidget.initiallyLaunchedFromHomeWidget().then((launched) {
      if (launched != null && launched) {
        _handleWidgetLaunch();
      }
    });
    updateHomeWidget();
  }

  Future<void> _launchedFromWidget(Uri? uri) async {
    _handleWidgetLaunch();
  }

  Future<void> _handleWidgetLaunch() async {
    String? action = await HomeWidget.getWidgetData(sectionKey) as String?;
    if (action != null) {
      switch (action) {
        case recordAudioAction:
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordAudioScreen()));
          break;
        case openCameraAction:
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OpenCameraScreen()));
          break;
        case openGalleryAction:
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OpenGalleryScreen()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: const Center(child: Text("This is the app's Home Page")));
  }
}
