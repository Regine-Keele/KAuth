import 'package:cashguard/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

Future<dynamic> showTransDialog(
    {required BuildContext context,
    required bool isGenuine,
    required int transNum,
    required Image image,
    required String date,
    double? width}) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: bgWhite,
                        borderRadius: BorderRadius.circular(30.0)),
                    margin: EdgeInsets.only(right: 12, top: 40),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          child: image,
                          padding: EdgeInsets.symmetric(vertical: 60),
                        ),
                        Text(
                          "This banknote is",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: darkGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        ),
                        Text(
                          isGenuine ? "Genuine!" : "Fake!",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              height: 1.1,
                              color: isGenuine ? genuineGreen : fakeRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Transaction #${transNum.toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: disabledGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          date.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: disabledGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundColor: bgWhite,
                        child: Image.asset(
                          isGenuine ? check : cross,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    top: 35,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 18.0,
                            backgroundColor: primaryColor,
                            child: Icon(Icons.close, color: pureWhite),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOut);
      });
}
