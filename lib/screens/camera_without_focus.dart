// ignore_for_file: unused_catch_stack, override_on_non_overriding_member

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:snap_focus_area/screens/display_captured_image.dart';
import 'package:snap_focus_area/widgets/camera_control_button.dart';

/// CameraWithoutFocus is the Main Application.
class CameraWithoutFocus extends StatefulWidget {
  /// Default Constructor
  final List<CameraDescription> cameras;
  final ResolutionPreset resolutionPreset;
  final bool showFlash;
  final double maxControllerBoxWidth;
  final Widget? Function(List<CameraDescription>, CameraController)?
      controlOptionsBuilder;
  CameraWithoutFocus(
      {super.key,
      required this.cameras,
      this.resolutionPreset = ResolutionPreset.high,
      this.showFlash = false,
      this.maxControllerBoxWidth = 300,
      this.controlOptionsBuilder})
      : assert(cameras.isNotEmpty, "Sorry Cannot proceed without Cameras");

  @override
  State<CameraWithoutFocus> createState() => _CameraWithoutFocusState();
}

class _CameraWithoutFocusState extends State<CameraWithoutFocus> {
  late CameraController controller;
  late CameraDescription currentCamera;
  late bool showFlash;

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
    controller.initialize().then((_) {
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
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
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
    } on CameraException catch (e, s) {
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
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.controlOptionsBuilder != null
                ? widget.controlOptionsBuilder!(widget.cameras, controller)
                : Container(
                    constraints:
                        BoxConstraints(maxWidth: widget.maxControllerBoxWidth),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CameraControlButton(
                          icon: const Icon(
                            Icons.photo_camera,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final imageFile = await controller.takePicture();
                            final displayImage = kIsWeb
                                ? Image.memory(await imageFile.readAsBytes())
                                : Image.file(File(imageFile.path));
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisplayCapturedImage(
                                    image: displayImage,
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
                              final flashMode =
                                  showFlash ? FlashMode.off : FlashMode.always;
                              await controller.setFlashMode(flashMode);
                              showFlash = !showFlash;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            icon: Icon(
                              showFlash ? Icons.flash_off : Icons.flash_auto,
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
                  ),
          )
        ],
      ),
    );
  }
}
