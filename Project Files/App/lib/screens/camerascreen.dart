// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({Key? key}) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   File? _imageFile;
//   final picker = ImagePicker();

//   Future<void> _getImage(ImageSource source) async {
//     final pickedFile = await picker.pickImage(source: source);

//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//         _processImage();
//       }
//     });
//   }

//   void _processImage() {
//     if (_imageFile != null) {
//       // Read the file
//       final image = img.decodeImage(File(_imageFile!.path).readAsBytesSync())!;

//       // Convert to grayscale
//       final grayscale = img.grayscale(image);

//       // Apply edge detection (simple Sobel filter)
//       final edged = img.sobel(grayscale);

//       // Save the processed image
//       final processed = img.encodeJpg(edged);
//       _imageFile = File(_imageFile!.path.replaceAll('.jpg', '_processed.jpg'))
//         ..writeAsBytesSync(processed);

//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camera Screen'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _imageFile != null
//                 ? Image.file(_imageFile!)
//                 : const Text('No image selected.'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _getImage(ImageSource.camera),
//               child: const Text('Take Picture'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => _getImage(ImageSource.gallery),
//               child: const Text('Select from Gallery'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<String> _pictures = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              child: const Text("Scan Documents"),
            ),
            // Display the scanned images
            for (var picture in _pictures) Image.file(File(picture)),
          ],
        ),
      ),
    );
  }

  // Method to scan documents and update the picture list
  void onPressed() async {
    List<String> pictures;
    try {
      // Trigger the document scanner and get the scanned images
      pictures = await CunningDocumentScanner.getPictures() ?? [];

      if (!mounted) return;

      setState(() {
        _pictures = pictures;
      });
    } catch (exception) {
      // Handle any exceptions that occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning documents: $exception')),
      );
    }
  }
}
