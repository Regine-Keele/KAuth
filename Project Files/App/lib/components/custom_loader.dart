import 'package:cashguard/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<dynamic> showLoaderDialog(
    {required BuildContext context, String? text}) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return Future.value(false);
          },
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                height: 70,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: pureWhite),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 6.0,
                      ),
                    ),
                    if (text != null)
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(
                              height: 1.1,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: cardText),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
