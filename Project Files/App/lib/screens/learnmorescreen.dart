import 'package:cashguard/constants.dart';
import 'package:cashguard/controllers/onboarding_controller.dart';
import 'package:cashguard/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

class LearnmoreScreen extends StatelessWidget {
  const LearnmoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            physics: BouncingScrollPhysics(),
            children: [
              GuidePage(
                size: size,
                title: "NGC",
                image: ngcImage,
                subtitle:
                    "New Generation Currency Banknotes was launch way back December 2010. features enhanced security features and modern design elements. These banknotes showcase prominent national heroes and landmarks, with advanced printing techniques to deter counterfeiting.",
              ),
              GuidePage(
                size: size,
                title: "eNGC",
                image: engcImage,
                subtitle:
                    "Enhanced New Generation Currency Banknotes was launch way back July 2020. It incorporates new anti-counterfeiting measures such as more sophisticated holographic elements and tactile features to aid the visually impaired.",
              ),
              GuidePage(
                size: size,
                title: "Polymer",
                image: polymerImage,
                subtitle:
                    "Polymer banknotes was launched back from April 2022, are made from a durable, plastic-like material that offers greater resistance to wear and tear. These banknotes are easier to clean and more environmentally friendly compared to paper-based notes.",
              ),
              ContactsPage(size: size, title: "Contact Details for BSP"),
            ],
          ),

          /// Skip Button
          Obx(() => controller.currentPageIndex.value == 3
              ? Container()
              : LearnmoreSkip()),

          /// Dot Navigation SmoothingIndicator
          const LearnmoreDotNavigation(),

          /// Circular Button
          const LearnmoreNextButton()
        ],
      ),
    );
  }
}

class LearnmoreNextButton extends StatelessWidget {
  const LearnmoreNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 30,
        bottom: kBottomNavigationBarHeight,
        child: Obx(
          () => ElevatedButton(
            onPressed: () {
              if (OnboardingController.instance.currentPageIndex.value == 3) {
                Get.offAll(() => Homescreen());
              } else {
                OnboardingController.instance.nextPage();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: OnboardingController.instance.currentPageIndex.value == 3
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))
                  : CircleBorder(),
              backgroundColor: primaryColor,
              iconColor: pureWhite,
              minimumSize:
                  OnboardingController.instance.currentPageIndex.value == 3
                      ? Size(120, 56)
                      : Size(56, 56),
            ),
            child: OnboardingController.instance.currentPageIndex.value == 3
                ? Text("Home",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: pureWhite))
                : Icon(Icons.keyboard_arrow_right_rounded),
          ),
        ));
  }
}

class LearnmoreDotNavigation extends StatelessWidget {
  const LearnmoreDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
        bottom: kBottomNavigationBarHeight,
        left: 50,
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 4,
          effect: const ExpandingDotsEffect(
              activeDotColor: primaryColor, dotHeight: 6),
        ));
  }
}

class LearnmoreSkip extends StatelessWidget {
  const LearnmoreSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: kToolbarHeight,
        right: 30,
        child: TextButton(
          onPressed: () => OnboardingController.instance.skipPage(),
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ));
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({
    super.key,
    required this.size,
    required this.title,
  });

  final Size size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(width: size.width * 0.2, image: AssetImage(bspImage)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColorLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            margin: EdgeInsets.only(top: 20),
            height: 300,
            decoration: BoxDecoration(
                color: primaryColorLight,
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
                    child: Container(
                  height: 300,
                  width: size.width - 60,
                  child: Container(
                    height: 300,
                    width: size.width * 0.6,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "For further information, you may contact the following :",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          Text(
                            "Address:",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "A. Mabini St. cor. P. Ocampo St.,Malate Manila, Philippines 1004",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Contact Number:",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "(+632) 8811-1277 (8811-1BSP)",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Email:",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "bspmail@bsp.gov.ph",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: pureWhite),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
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
    );
  }
}

class GuidePage extends StatelessWidget {
  const GuidePage({
    super.key,
    required this.size,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final Size size;
  final String image, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: primaryColorLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Image(image: AssetImage(image)),
        ],
      ),
    );
  }
}
