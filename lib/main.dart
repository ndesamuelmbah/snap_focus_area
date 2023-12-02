import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:snap_focus_area/firebase_options.dart';
import 'package:snap_focus_area/screens/camera_snap_focus_area.dart';
import 'package:snap_focus_area/screens/camera_without_focus.dart';
import 'package:snap_focus_area/widgets/action_button.dart';
import 'package:snap_focus_area/widgets/overlay/card_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

//Command to deploy to firebase.
//flutter clean && flutter pub get && flutter build web --release && firebase deploy
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap and Crop with Overalay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Camera Snap Focus Area'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CameraDescription> allCameras = [];
  final _formKey = GlobalKey<FormState>();

  double cornerRadius = 0.0;
  double ratio = 0.2;
  double widthFraction = 0.1;

  Future<void> setCameras() async {
    if (allCameras.isNotEmpty) {
      return;
    }
    final perms = await Permission.camera.request();

    print(perms);
    if (perms.isGranted) {
      allCameras = await availableCameras();
      setState(() {});
    } else {
      allCameras = await availableCameras();
      print(allCameras);
      await showDialogForRequestingCamera();
    }
  }

  Future showDialogForRequestingCamera() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Container(
          width: 250,
          height: 50,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.indigo.shade200,
          ),
          // color: Colors.yellow,
          child: const Row(
            children: [
              Icon(Icons.camera_alt, size: 40, color: Colors.red),
              Text(
                'Camera Permissions DENIED',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('Do you want to grant the permissions now'),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(
                  text: "YES",
                  color: Colors.green,
                  radius: 5,
                  minWidth: 100,
                  backgroundColor: Colors.green.shade100,
                  fontWeight: FontWeight.bold,
                  onPressed: () async {
                    await openAppSettings().then(
                        (value) => print('Settings opened with value $value'));
                  }),
              ActionButton(
                  text: "NO",
                  color: Colors.grey,
                  radius: 5,
                  minWidth: 100,
                  backgroundColor: Colors.grey.shade200,
                  fontWeight: FontWeight.bold,
                  onPressed: () async {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ListView(
            children: <Widget>[
              Card(
                color: Colors.indigo.shade100,
                child: ListTile(
                  title: const Text(
                    'Before you Begin',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                      'In order to use this app, your device must grant Access to Camera and Microphone.'),
                  onTap: setCameras,
                ),
              ),
              Card(
                color: Colors.indigo.shade100.withAlpha(100),
                child: ListTile(
                  minLeadingWidth: 0,
                  onTap: () async {
                    const githubUrl =
                        'https://github.com/ndesamuelmbah/snap_focus_area.git';
                    try {
                      await launchUrl(Uri.parse(githubUrl));
                    } catch (e) {
                      await Clipboard.setData(ClipboardData(text: githubUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 4),
                          backgroundColor: Colors.grey,
                          content: Text('Url has been copied',
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                      await HapticFeedback.vibrate();
                    }
                  },
                  contentPadding: const EdgeInsets.only(left: 5),
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/images/githubIcon.png',
                        ),
                      ),
                    ],
                  ),
                  title: const Text(
                    'Want to Try this Code',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Mono'),
                  ),
                  subtitle: const Text(
                    'Head to Github and clone this repository. Don\'t forget to give it a star if the code deserves one.',
                    style: TextStyle(fontFamily: 'Mono', fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ActionButton(
                  text: "Snap without cropping Image",
                  color: Colors.indigo,
                  radius: 5,
                  backgroundColor: Colors.indigo.shade100,
                  fontWeight: FontWeight.bold,
                  onPressed: () async {
                    await setCameras();
                    if (mounted && allCameras.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraWithoutFocus(
                            cameras: allCameras,
                            showFlash: true,
                          ),
                        ),
                      );
                    }
                  }),
              const SizedBox(
                height: 10,
              ),
              ActionButton(
                  text: "Snap and Crop - Custom Overlay Ovoid",
                  color: Colors.indigo,
                  radius: 5,
                  backgroundColor: Colors.indigo.shade100,
                  fontWeight: FontWeight.bold,
                  onPressed: () async {
                    await setCameras();
                    if (mounted && allCameras.isNotEmpty) {
                      final cardOverlay = CardOverlay.fromValues(
                        widthFraction: 0.4,
                        cornerRadius: 100,
                        ratio: 1,
                      );
                      final screenWidth = MediaQuery.of(context).size.width;
                      final topRadius =
                          cardOverlay.widthFraction * screenWidth / 3;
                      final bottomRadius = topRadius * 2;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraSnapFocusArea(
                              cameras: allCameras,
                              overlayBoxDecoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.elliptical(topRadius,
                                      topRadius), // Adjust the values for the oval shape
                                  bottom: Radius.elliptical(
                                      bottomRadius, bottomRadius),
                                ),
                              ),
                              cardOverlay: cardOverlay),
                        ),
                      );
                    }
                  }),
              const SizedBox(
                height: 10,
              ),
              ActionButton(
                  text: "Snap and Crop - Custom Overlay Card",
                  color: Colors.indigo,
                  radius: 5,
                  backgroundColor: Colors.indigo.shade100,
                  fontWeight: FontWeight.bold,
                  onPressed: () async {
                    await setCameras();
                    if (mounted && allCameras.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraSnapFocusArea(
                            cameras: allCameras,
                            resolutionPreset: ResolutionPreset.veryHigh,
                            cardOverlay: CardOverlay.fromValues(
                                widthFraction: 0.7,
                                cornerRadius: 10,
                                ratio: 1.5),
                          ),
                        ),
                      );
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                      color: Colors.indigo.shade100,
                      child: ListTile(
                        title: const Text(
                          'Or use your custom overlay values',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                            'Enter the values for each field below and hit the submit button'),
                        onTap: setCameras,
                      ),
                    ),
                    const SizedBox(height: 10),
                    getContainer(
                      'Crop Boundary Radius',
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }

                        double inputValue = double.tryParse(value) ?? 0.0;

                        if (inputValue < 0) {
                          return 'Please enter a value greater than or equal to 0';
                        }

                        cornerRadius = inputValue;

                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    getContainer(
                      'Ratio',
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }

                        double inputValue = double.tryParse(value) ?? 0.0;

                        if (inputValue < 0.2 || inputValue > 2) {
                          return 'Please enter a value between 0.2 and 2';
                        }

                        ratio = inputValue;

                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    getContainer(
                      'Width Factor',
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }

                        double inputValue = double.tryParse(value) ?? 0.0;

                        if (inputValue < 0.1 || inputValue > 1) {
                          return 'Please enter a value between 0.1 and 1';
                        }

                        widthFraction = inputValue;

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ActionButton(
                        text: "Submit Custom Overlay Values",
                        color: Colors.indigo,
                        radius: 5,
                        backgroundColor: Colors.indigo.shade100,
                        fontWeight: FontWeight.bold,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await setCameras();
                            if (mounted && allCameras.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraSnapFocusArea(
                                    cameras: allCameras,
                                    resolutionPreset: ResolutionPreset.veryHigh,
                                    cardOverlay: CardOverlay.fromValues(
                                        widthFraction: widthFraction,
                                        cornerRadius: cornerRadius,
                                        ratio: ratio),
                                  ),
                                ),
                              );
                            }
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getContainer(String labelText, String? Function(String?) validator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: labelText,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}
