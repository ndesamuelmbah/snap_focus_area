import 'package:flutter/material.dart';
import 'package:snap_focus_area/widgets/action_button.dart';

class DisplayCapturedImage extends StatelessWidget {
  final Image image; // Replace with the path or URL of your image

  const DisplayCapturedImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ListView(
            children: [
              Card(
                color: Colors.indigo.shade100,
                child: const ListTile(
                  title: Text(
                    'Displaying captured image, can scroll',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      'The captured image is in the red container below, with not stretch in its height or with.'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.red)),
                  child: image
                  // kIsWeb
                  //     ?                     Image.network(imagePath)
                  //     : Image.file(
                  //         File(imagePath),
                  //       ),
                  ),
              const SizedBox(
                height: 20,
              ),
              ActionButton(
                  text: 'Close',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  radius: 5,
                  backgroundColor: Colors.red.shade100,
                  horizontalPadding: 3,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
