import 'package:cashguard/components/material_button_icon.dart';
import 'package:cashguard/components/transaction_popup.dart';
import 'package:cashguard/components/banknote_authenticator.dart';
import 'package:cashguard/components/loading_dialog.dart';
import 'package:cashguard/constants.dart';
import 'package:cashguard/controllers/application_controller.dart';
import 'package:cashguard/screens/learnmorescreen.dart';
import 'package:cashguard/screens/transactionscreen.dart';
import 'package:cashguard/screens/onboardingscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Interpreter? _interpreter;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _resizedImageBytes;
  Uint8List? _croppedImageBytes1;
  Uint8List? _croppedImageBytes2;
  Uint8List? _processedImageBytes1;
  Uint8List? _processedImageBytes2;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model/model-7v2.tflite');
  }

  Future<List<double>> preprocessImage(cv.Mat cvImage) async {
    // Convert OpenCV image to Image package format
    img.Image image = img.Image.fromBytes(
      cvImage.cols,
      cvImage.rows,
      cvImage.data,
      format: img.Format.bgr,
    );

    // Resize the image to 299x299 if it's not already that size
    if (image.width != 299 || image.height != 299) {
      image = img.copyResize(image, width: 299, height: 299);
    }

    // Convert the image to a list of normalized pixel values
    List<double> pixelList = [];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        // Normalize RGB values to [0, 1]
        pixelList.add(r / 255.0);
        pixelList.add(g / 255.0);
        pixelList.add(b / 255.0);
      }
    }

    // Reshape the list to add an extra dimension (equivalent to np.expand_dims(img_array, axis=0))
    // This creates a 4D list with shape [1, 299, 299, 3]
    List<List<List<List<double>>>> expandedPixelList = [
      List.generate(
        299,
        (y) => List.generate(
          299,
          (x) => [
            pixelList[(y * 299 + x) * 3],
            pixelList[(y * 299 + x) * 3 + 1],
            pixelList[(y * 299 + x) * 3 + 2],
          ],
        ),
      )
    ];

    // Flatten the 4D list back into a 1D list for easier handling
    List<double> flattenedExpandedList = expandedPixelList
        .expand((plane) => plane)
        .expand((row) => row)
        .expand((pixel) => pixel)
        .toList();

    return flattenedExpandedList;
  }

  Future<void> processAndPredictImage(
      String imagePath, BuildContext context) async {
    //Loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const LoadingDialog(),
    );

    // Add a small delay to ensure the loader appears
    await Future.delayed(Duration(milliseconds: 1500));

    // If interpreter is not loaded
    if (_interpreter == null) {
      print('Interpreter is not initialized');
      Navigator.of(context).pop(); // Dismiss the loading dialog
      return;
    }

    // Read and preprocess the image
    var imageBytes = await File(imagePath).readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) return;

    // Resize the image to 3844x1575
    var resizedImage = img.copyResize(image, width: 3844, height: 1575);
    setState(() {
      _resizedImageBytes = Uint8List.fromList(img.encodePng(resizedImage));
    });

    // ROI parameters for first region(Concealed Value)
    int x1 = 471;
    int y1 = 0;
    int width1 = 475;
    int height1 = 555;

    // ROI parameters for second region(OVD)
    int x2 = 465;
    int y2 = 633;
    int width2 = 516;
    int height2 = 559;

    // Crop the image based on ROIs
    var croppedImage1 = img.copyCrop(resizedImage, x1, y1, width1, height1);
    setState(() {
      _croppedImageBytes1 = Uint8List.fromList(img.encodePng(croppedImage1));
    });

    var croppedImage2 = img.copyCrop(resizedImage, x2, y2, width2, height2);
    setState(() {
      _croppedImageBytes2 = Uint8List.fromList(img.encodePng(croppedImage2));
    });

    // Resize cropped images to model input size
    croppedImage1 = img.copyResize(croppedImage1, width: 299, height: 299);
    croppedImage2 = img.copyResize(croppedImage2, width: 299, height: 299);

    // Convert img.Image to cv.Mat
    Uint8List bytes1 = Uint8List.fromList(img.encodeBmp(croppedImage1));
    Uint8List bytes2 = Uint8List.fromList(img.encodeBmp(croppedImage2));

    var cvImage1 = await cv.imdecode(bytes1, cv.IMREAD_COLOR);
    var cvImage2 = await cv.imdecode(bytes2, cv.IMREAD_COLOR);

    var img_gray1 = await cv.cvtColor(cvImage1, cv.COLOR_BGR2GRAY);
    var img_gray2 = await cv.cvtColor(cvImage2, cv.COLOR_BGR2GRAY);

    var edges1 = await cv.canny(img_gray1, 100, 200);
    var edges2 = await cv.canny(img_gray2, 100, 200);

    var img_bgr1 = await cv.cvtColor(edges1, cv.COLOR_GRAY2BGR);
    var img_bgr2 = await cv.cvtColor(edges2, cv.COLOR_GRAY2BGR);

    // Preprocess the images
    List<double> input1 = await preprocessImage(img_bgr1);
    List<double> input2 = await preprocessImage(img_bgr2);

    // After processing img_bgr1 and img_bgr2
    var (success1, processedBytes1) = await cv.imencode('.png', img_bgr1);
    var (success2, processedBytes2) = await cv.imencode('.png', img_bgr2);

    if (success1 && success2) {
      setState(() {
        _processedImageBytes1 = processedBytes1;
        _processedImageBytes2 = processedBytes2;
      });
    } else {
      print('Failed to encode one or both images');
    }

    // Combine inputs if necessary
    var inputTensor1 = Float32List.fromList(input1).reshape([1, 299, 299, 3]);
    var output1 = List.filled(1, 0.0).reshape([1, 1]);

    var inputTensor2 = Float32List.fromList(input2).reshape([1, 299, 299, 3]);
    var output2 = List.filled(1, 0.0).reshape([1, 1]);

    try {
      Navigator.of(context).pop(); // Dismiss the loading dialog

      _interpreter!.run(inputTensor1, output1);
      _interpreter!.run(inputTensor2, output2);
      double concealedValueScore = output1[0][0];
      double ovdScore = output2[0][0];

      // Create an instance of BanknoteAuthenticator
      final authenticator = BanknoteAuthenticator();

      // Combine scores and get prediction
      double combinedScore =
          authenticator.combineScores(ovdScore, concealedValueScore);
      String prediction = authenticator.getPrediction(combinedScore);
      bool isReal = prediction == 'Real';

      print(
          'OVD Score: $ovdScore, Concealed Value Score: $concealedValueScore');
      print('Combined Score: ${combinedScore.toStringAsFixed(2)}');
      print('Prediction: $prediction');

      final player = AudioPlayer();
      if (prediction == 'Real') {
        await player.play(AssetSource('audio/real_audio.mp3'));
      } else {
        await player.play(AssetSource('audio/fake_audio.mp3'));
      }

      DateFormat dateFormat = DateFormat("yyyyMMddHHmmss");
      String datetime = dateFormat.format(DateTime.now());
      await ApplicationController.instance.incrementTransNumber();
      if (_resizedImageBytes != null) {
        Directory docuDir = await getApplicationDocumentsDirectory();
        File trnImage =
            await File(path.join(docuDir.path, "${datetime + ".jpg"}"))
                .create();
        await trnImage.writeAsBytes(_resizedImageBytes!);
        ApplicationController.instance.createTransaction(
            [ApplicationController.instance.numTrans.value, datetime, isReal]);
      }

      showTransDialog(
          context: context,
          isGenuine: isReal,
          transNum: ApplicationController.instance.numTrans.value,
          image: Image.memory(_resizedImageBytes!),
          date: datetime);
      //     .then((_) {
      //   // This code will run after the TransDialog is closed
      //   _showPredictionResult(
      //       prediction, combinedScore, ovdScore, concealedValueScore);
      // });
    } catch (e) {
      print('Error running inference: $e');
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await processAndPredictImage(image.path, context);
    }
  }

  Future _pickCropAndPredictImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: primaryColor,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        await processAndPredictImage(croppedFile.path, context);
      }
    }
  }

  void _showPredictionResult(String prediction, double combinedScore,
      double ovdScore, double concealedScore) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Prediction Result',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 26, fontWeight: FontWeight.w600, color: primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Combined Score: ${(combinedScore * 100).toStringAsFixed(2)}',
                ),
                Text(
                  'OVD Score: ${(ovdScore * 100).toStringAsFixed(2)}',
                ),
                Text(
                    'Concealed Score: ${(concealedScore * 100).toStringAsFixed(2)}%'),
                SizedBox(height: 10),
                _resizedImageBytes != null
                    ? Column(
                        children: [
                          Text('Resized Image:'),
                          Image.memory(_resizedImageBytes!),
                        ],
                      )
                    : Container(),
                SizedBox(height: 3),
                _croppedImageBytes1 != null
                    ? Column(
                        children: [
                          Text('Cropped Image 1:'),
                          Image.memory(_croppedImageBytes1!),
                        ],
                      )
                    : Container(),
                SizedBox(height: 3),
                _croppedImageBytes2 != null
                    ? Column(
                        children: [
                          Text('Cropped Image 2:'),
                          Image.memory(_croppedImageBytes2!),
                        ],
                      )
                    : Container(),
                SizedBox(height: 3),
                _processedImageBytes1 != null
                    ? Column(
                        children: [
                          Text('Processed Image 1:'),
                          Image.memory(_processedImageBytes1!),
                        ],
                      )
                    : Container(),
                SizedBox(height: 3),
                _processedImageBytes2 != null
                    ? Column(
                        children: [
                          Text('Processed Image 2:'),
                          Image.memory(_processedImageBytes2!),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: bgWhite,
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      width: size.width,
                      height: 210,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [bgTint, primaryColorDark],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.90]),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(40))),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Opacity(
                              opacity: 0.3,
                              child: Image.asset(
                                kauthLogoFull,
                                height: 300,
                                width: 300,
                              ),
                            ),
                          ),
                          Positioned(
                              left: 0,
                              bottom: 0,
                              child: Container(
                                height: 200,
                                width: size.width,
                                padding: EdgeInsets.fromLTRB(50, 0, 50, 40),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome to",
                                        style: GoogleFonts.poppins(
                                            fontSize: 56,
                                            fontWeight: FontWeight.w600,
                                            color: pureWhite,
                                            height: 1.1),
                                      ),
                                      Text(
                                        "KAuth",
                                        style: GoogleFonts.poppins(
                                            fontSize: 56,
                                            fontWeight: FontWeight.w600,
                                            color: pureWhite,
                                            height: 1.1),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 50),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: bgWhite,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 15,
                                      color: primaryColor.withOpacity(0.3),
                                      offset: Offset(2, 2))
                                ]),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Result History",
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            Get.to(() => TransactionScreen(),
                                                transition: Transition.downToUp,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.easeInOut);
                                          },
                                          child: Text(
                                            "See all",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(),
                                          ))
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Obx(
                                  () => ApplicationController
                                              .instance.prevTrans.length >
                                          0
                                      ? Column(children: [
                                          ...[
                                            for (int i = 0;
                                                i <
                                                    (ApplicationController
                                                                .instance
                                                                .prevTrans
                                                                .length >=
                                                            3
                                                        ? 3
                                                        : ApplicationController
                                                            .instance
                                                            .prevTrans
                                                            .length);
                                                i++)
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 1),
                                                child: TransactionCard(
                                                  index: i,
                                                  transNum: int.parse(
                                                      ApplicationController
                                                          .instance
                                                          .prevTrans[
                                                              ApplicationController
                                                                      .instance
                                                                      .prevTrans
                                                                      .length -
                                                                  1 -
                                                                  i][0]
                                                          .toString()),
                                                  date: ApplicationController
                                                      .instance
                                                      .prevTrans[
                                                          ApplicationController
                                                                  .instance
                                                                  .prevTrans
                                                                  .length -
                                                              1 -
                                                              i][1]
                                                      .toString(),
                                                  isReal: ApplicationController
                                                              .instance
                                                              .prevTrans[ApplicationController
                                                                      .instance
                                                                      .prevTrans
                                                                      .length -
                                                                  1 -
                                                                  i][2]
                                                              .toString()
                                                              .toLowerCase() ==
                                                          "true"
                                                      ? true
                                                      : false,
                                                ),
                                              ),
                                          ]
                                        ])
                                      : Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "No previous transactions found.",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: disabledGrey),
                                          )),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 190,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 15,
                                      color: primaryColor.withOpacity(0.3),
                                      offset: Offset(2, 2))
                                ]),
                            child: Stack(
                              children: [
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 190,
                                      width: size.width - 20,
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 190,
                                        width: size.width / 2,
                                        child: Image.asset(knowmore),
                                        alignment: Alignment.bottomRight,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    )),
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      height: 190,
                                      width: size.width - 60,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        height: 190,
                                        width: size.width * 0.6,
                                        padding:
                                            EdgeInsets.fromLTRB(20, 20, 0, 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Would you like to know more about the 1000 Philippine Banknotes?",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: pureWhite),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            MaterialButtonIcon(
                                              onTap: () {
                                                {
                                                  Get.to(
                                                      () => LearnmoreScreen(),
                                                      transition:
                                                          Transition.downToUp,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeInOut);
                                                }
                                              },
                                              withIcon: false,
                                              withText: true,
                                              text: "Learn more!",
                                              fontColor: primaryColor,
                                              buttonColor: pureWhite,
                                              height: 30,
                                              width: 130,
                                            )
                                          ],
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              child: Container(
                width: size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 70,
                        decoration: BoxDecoration(
                            color: pureWhite,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 15,
                                  color: primaryColorDark.withOpacity(0.2))
                            ]),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 70,
                              width: 80,
                              padding: EdgeInsets.only(left: 7.5),
                              child: GestureDetector(
                                onTap: () {
                                  {
                                    Get.to(() => OnboardingScreen(),
                                        transition: Transition.downToUp,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child: Icon(
                                  Icons.question_mark_rounded,
                                  size: 35,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 70,
                              width: 80,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 70,
                              width: 80,
                              padding: EdgeInsets.only(right: 7.5),
                              child: GestureDetector(
                                onTap: () async {
                                  await _pickCropAndPredictImage(context);
                                },
                                child: Icon(
                                  Icons.photo_library_rounded,
                                  size: 35,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MaterialButtonIcon(
                        onTap: () async {
                          try {
                            List<String> pictures =
                                await CunningDocumentScanner.getPictures(
                                        noOfPages: 1,
                                        isGalleryImportAllowed: true) ??
                                    [];
                            if (pictures.isNotEmpty) {
                              await processAndPredictImage(
                                  pictures[0], context);
                            }
                          } catch (exception) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error capturing or processing image: $exception'),
                              ),
                            );
                          }
                        },
                        withIcon: true,
                        withText: false,
                        height: 80,
                        width: 80,
                        icon: Icons.camera_alt,
                        iconSize: 40,
                        iconColor: pureWhite,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

class TransactionCard extends StatefulWidget {
  final int index;
  final int transNum;
  final String date;
  final bool isReal;
  const TransactionCard(
      {super.key,
      required this.index,
      required this.transNum,
      required this.date,
      required this.isReal});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: bgWhite,
        elevation: isHovered ? 10 : 0,
        shadowColor: primaryColorLight.withOpacity(0.2),
        child: InkWell(
          onHover: (hover) {
            setState(() {
              isHovered = hover;
            });
          },
          onTap: () async {
            Directory docuDir = await getApplicationDocumentsDirectory();
            String originalImagePath =
                path.join(docuDir.path, "${widget.date}.jpg");

            // Compress the image before displaying it
            File compressedImage = await compressImage(File(originalImagePath));

            // Display the compressed image in the dialog
            showTransDialog(
              context: context,
              isGenuine: widget.isReal,
              transNum: widget.transNum,
              image: Image.file(compressedImage), // Using compressed image
              date:
                  "${widget.date.substring(0, 4)}-${widget.date.substring(4, 6)}-${widget.date.substring(6, 8)} ${widget.date.substring(8, 10)}:${widget.date.substring(10, 12)}:${widget.date.substring(12, 14)}",
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryColor.withOpacity(0.2),
          highlightColor: primaryColor.withOpacity(0.1),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transaction #${widget.transNum.toString()}",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${widget.date.substring(0, 4)}-${widget.date.substring(4, 6)}-${widget.date.substring(6, 8)} ${widget.date.substring(8, 10)}:${widget.date.substring(10, 12)}:${widget.date.substring(12, 14)}",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: disabledGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                Container(
                  width: 80,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    widget.isReal ? "Real" : "Fake",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: widget.isReal ? genuineGreen : fakeRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    // Add delete confirmation dialog logic
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete Transaction"),
                          content: Text(
                              "Are you sure you want to delete this transaction?"),
                          actions: [
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: Text("Confirm"),
                              onPressed: () {
                                // If confirmed, delete the transaction
                                ApplicationController.instance
                                    .deleteTransaction(widget.transNum);

                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to compress the image
  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${widget.date}_compressed.jpg');

    // Perform the image compression
    XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, // Source image path
      targetPath, // Destination path
      quality: 40, // Set quality level (lower value compresses more)
    );

    // Convert XFile to File and return the compressed image if successful, otherwise return the original image
    return compressedImage != null ? File(compressedImage.path) : file;
  }
}

class SelectButton extends StatefulWidget {
  final VoidCallback onTap;
  final String buttonText;
  final IconData icon;
  const SelectButton(
      {super.key,
      required this.onTap,
      required this.buttonText,
      required this.icon});

  @override
  State<SelectButton> createState() => _SelectButtonState();
}

class _SelectButtonState extends State<SelectButton> {
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(40),
        color: bgWhite,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (details) {
            setState(() {
              isPressed = true;
            });
          },
          onTapUp: (details) {
            setState(() {
              isPressed = false;
            });
          },
          borderRadius: BorderRadius.circular(30),
          splashColor: primaryColor,
          highlightColor: primaryColor.withOpacity(0.1),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryColor, width: 4.0)),
              child: Column(
                children: [
                  Icon(
                    widget.icon,
                    color: isPressed ? pureWhite : primaryColor,
                    size: 50,
                  ),
                  Text(
                    widget.buttonText,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        color: isPressed ? pureWhite : disabledGrey,
                        height: 1.1,
                        fontSize: 16),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
