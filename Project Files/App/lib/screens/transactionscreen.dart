import 'dart:typed_data';

import 'package:cashguard/constants.dart';
import 'package:cashguard/controllers/application_controller.dart';
import 'package:cashguard/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: size.height,
                    width: size.width,
                    color: bgWhite,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 90, 20, 50),
                      child: Column(
                        children: [
                          for (int i = 0;
                              i <
                                  ApplicationController
                                      .instance.prevTrans.value.length;
                              i++)
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: TransactionCard(
                                index: ApplicationController
                                    .instance.prevTrans[i][0],
                                transNum: ApplicationController
                                    .instance.prevTrans[i][0],
                                date: ApplicationController
                                    .instance.prevTrans[i][1]
                                    .toString(),
                                isReal: ApplicationController
                                            .instance.prevTrans[i][2]
                                            .toString() ==
                                        "true"
                                    ? true
                                    : false,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 80,
                    width: size.width,
                    decoration: BoxDecoration(color: primaryColor, boxShadow: [
                      BoxShadow(
                          blurRadius: 15, color: primaryColor.withOpacity(0.2))
                    ]),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 30,
                            color: pureWhite,
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            "History",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                color: pureWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        ))
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
