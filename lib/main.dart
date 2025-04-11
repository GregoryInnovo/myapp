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
const openCameraAction = "openCameraAction";
const openGalleryAction = "openGalleryAction";
const sectionKey = "section";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId(appGroupId);
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
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
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/image.png');
    if (await file.exists()) {
      await HomeWidget.saveWidgetData<String>('imageUrl', file.uri.toString());
    }
    await HomeWidget.updateWidget(
        name: 'AppWidgetProvider', iOSName: 'AppWidget');
  } catch (e) {
    debugPrint('Error updating widget: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
    HomeWidget.initiallyLaunchedFromHomeWidget().then((wasLaunchedFromWidget) {
      if (wasLaunchedFromWidget == true) {
        _handleWidgetLaunch();
      }
    });
    updateHomeWidget();
  }

  Future<void> _handleWidgetLaunch() async {
    try {
      String? action = await HomeWidget.getWidgetData<String>(sectionKey);
      if (action != null && mounted) {
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
          default:
            debugPrint('Unknown action: $action');
        }
      }
    } catch (e) {
      debugPrint('Error handling widget launch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the app's Home Page"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordAudioScreen()),
                );
              },
              child: const Text('Record Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
