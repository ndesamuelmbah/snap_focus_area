import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//Here is a comment
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:snap_focus_area/screens/display_captured_image.dart';
import 'package:snap_focus_area/utils/crop_and_save_image.dart';
import 'package:snap_focus_area/widgets/camera_control_button.dart';
import 'package:snap_focus_area/widgets/overlay/card_overlay.dart';
import 'package:snap_focus_area/widgets/overlay/overlay_shape.dart';

/// CameraSnapFocusArea is the Main Application.
class CameraSnapFocusArea extends StatefulWidget with WidgetsBindingObserver {
  /// Default Constructor
  final List<CameraDescription> cameras;
  final ResolutionPreset resolutionPreset;
  final bool showFlash;
  final CardOverlay cardOverlay;
  final double maxControllerBoxWidth;
  final BoxDecoration? overlayBoxDecoration;
  final Widget? Function(List<CameraDescription>, CameraController)?
      controlOptionsBuilder;
  CameraSnapFocusArea(
      {super.key,
      required this.cameras,
      required this.cardOverlay,
      this.resolutionPreset = ResolutionPreset.high,
      this.showFlash = false,
      this.maxControllerBoxWidth = 300,
      this.controlOptionsBuilder,
      this.overlayBoxDecoration})
      : assert(cameras.isNotEmpty, "Sorry Cannot proceed without Cameras"),
        assert(maxControllerBoxWidth > 130,
            "Sorry, you need a minimum size of 130 for controller box");

  @override
  State<CameraSnapFocusArea> createState() => _CameraSnapFocusAreaState();
}

class _CameraSnapFocusAreaState extends State<CameraSnapFocusArea> {
  late CameraController controller;
  late CameraDescription currentCamera;
  late bool showFlash;
  late Size cameraSize;
  late Size previewSize;
  bool isProcessingImage = false;
  late double pixelRatio;
  double maxZoom = 1, minZoom = 1, currentZoom = 1;
  static final GlobalKey downloadObjectKey = GlobalKey();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    showFlash = widget.showFlash;
    currentCamera = widget.cameras.first;
    controller = CameraController(
      currentCamera,
      widget.resolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller.initialize().then((_) async {
      currentZoom = 1;
      if (!kIsWeb) {
        maxZoom = await controller.getMaxZoomLevel();
        minZoom = await controller.getMinZoomLevel();
      }
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    didChangeAppLifecycleState(AppLifecycleState.detached);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.
    if (!controller.value.isInitialized) {
      return;
    }
    // [Resource management] When inactive, dispose the controller
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // When resumed for example navigating away to a new page and popping it
      // Reinitialize the camera with the last camera that was used
      onNewCameraSelected(controller.description);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController oldController = controller;
    await oldController.dispose();

    final CameraController newCameraController = CameraController(
      cameraDescription,
      widget.resolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = newCameraController;

    // If the controller is updated then update the UI.
    newCameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      //TODO
      // if (cameraController.value.hasError) {
      //   showInSnackBar(
      //       'Camera error ${cameraController.value.errorDescription}');
      // }
    });

    try {
      await newCameraController.initialize();
      if (!kIsWeb) {
        await newCameraController.setZoomLevel(currentZoom);
      }
    } on CameraException catch (e) {
      // switch (e.code) {
      //   case 'CameraAccessDenied':
      //     showInSnackBar('You have denied camera access.');
      //     break;
      //   case 'CameraAccessDeniedWithoutPrompt':
      //     // iOS only
      //     showInSnackBar('Please go to Settings app to enable camera access.');
      //     break;
      //   case 'CameraAccessRestricted':
      //     // iOS only
      //     showInSnackBar('Camera access is restricted.');
      //     break;
      //   case 'AudioAccessDenied':
      //     showInSnackBar('You have denied audio access.');
      //     break;
      //   case 'AudioAccessDeniedWithoutPrompt':
      //     // iOS only
      //     showInSnackBar('Please go to Settings app to enable audio access.');
      //     break;
      //   case 'AudioAccessRestricted':
      //     // iOS only
      //     showInSnackBar('Audio access is restricted.');
      //     break;
      //   default:
      //     _showCameraException(e);
      //     break;
      // }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Card(
        color: Colors.indigo.shade100,
        child: const ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
          title: Text(
            'Initializing Camera',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Please grant Access to Camera and Microphone.'),
        ),
      );
    }
    final Widget cameraPreview = AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(
        controller,
        child: LayoutBuilder(
          builder: (context, constraints) {
            cameraSize = constraints.biggest;
            pixelRatio = cameraSize.width / controller.value.previewSize!.width;
            print('Original pixelRatio $pixelRatio');
            previewSize = controller.value.previewSize!;
            if (cameraSize.aspectRatio < 1 && previewSize.aspectRatio > 1) {
              previewSize = Size(previewSize.height, previewSize.width);
            }

            pixelRatio = cameraSize.width / previewSize.width;
            print('Aspect Ratio: ${1 / controller.value.aspectRatio}');
            print(
                'cameraSize: $cameraSize, Aspect Ratio: ${cameraSize.aspectRatio}');
            print(
                'previewSize: $previewSize, Aspect Ratio: ${previewSize.aspectRatio}');
            print('pixelRatio $pixelRatio');
            // print(
            //     'screenSize: $screenSize, Aspect Ratio: ${screenSize.aspectRatio}');
            return OverlayShape(widget.cardOverlay, downloadObjectKey,
                cameraScreenSize: cameraSize,
                overlayBoxDecoration: widget.overlayBoxDecoration);
          },
        ),
      ),
    );
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            cameraPreview,
            Align(
              alignment: Alignment.bottomCenter,
              child: widget.controlOptionsBuilder != null
                  ? widget.controlOptionsBuilder!(widget.cameras, controller)
                  : Container(
                      constraints: BoxConstraints(
                          maxWidth: widget.maxControllerBoxWidth),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.transparent.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!kIsWeb)
                            Slider(
                                value: currentZoom,
                                max: maxZoom,
                                label:
                                    '${(100 * currentZoom / maxZoom).toStringAsFixed(1)}%',
                                divisions: 10,
                                onChanged: (newZoom) async {
                                  if (minZoom <= newZoom &&
                                      newZoom <= maxZoom) {
                                    currentZoom = newZoom;
                                    await controller.setZoomLevel(newZoom);
                                    setState(() {});
                                  }
                                }),
                          if (kIsWeb)
                            Slider(
                                value: currentZoom,
                                max: maxZoom,
                                label:
                                    '${(100 * currentZoom / maxZoom).toStringAsFixed(1)}%',
                                divisions: 10,
                                onChanged: (newZoom) async {
                                  currentZoom = newZoom;
                                  setState(() {});
                                }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CameraControlButton(
                                icon: const Icon(
                                  Icons.photo_camera,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final image = await controller.takePicture();
                                  await controller.pausePreview();
                                  final croppedImage = await cropImageAndSave(
                                      image, cameraSize, downloadObjectKey,
                                      pixelRatio: pixelRatio,
                                      cardOverlay: widget.cardOverlay);
                                  await controller.resumePreview();
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DisplayCapturedImage(
                                          image: croppedImage,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              if (widget.showFlash)
                                CameraControlButton(
                                  onPressed: () async {
                                    for (int i = 10; i > 0; i--) {
                                      await HapticFeedback.vibrate();
                                    }
                                    final flashMode = showFlash
                                        ? FlashMode.off
                                        : FlashMode.always;
                                    await controller.setFlashMode(flashMode);
                                    showFlash = !showFlash;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(
                                    showFlash
                                        ? Icons.flash_off
                                        : Icons.flash_auto,
                                    color: Colors.yellow,
                                    size: 30,
                                  ),
                                ),
                              if (widget.cameras.length > 1)
                                CameraControlButton(
                                  onPressed: () async {
                                    final newCamera = widget.cameras.firstWhere(
                                        (camera) =>
                                            camera.lensDirection !=
                                            currentCamera.lensDirection);
                                    await onNewCameraSelected(newCamera);
                                  },
                                  icon: const Icon(
                                    Icons.cameraswitch_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              CameraControlButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await controller.pausePreview();
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
