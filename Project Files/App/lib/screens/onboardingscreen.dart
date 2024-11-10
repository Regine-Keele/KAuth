import 'package:cashguard/constants.dart';
import 'package:cashguard/controllers/onboarding_controller.dart';
import 'package:cashguard/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
              OnboardingPage(
                size: size,
                image: engcImage,
                title: onboardingTitle1,
                subtitle: onboardingSubtitle1,
              ),
              GuidePage(
                size: size,
                image: guide1,
                title: onboardingTitle2,
                subtitle: onboardingSubtitle2,
              ),
              GuidePage(
                size: size,
                image: guide2,
                title: onboardingTitle3,
                subtitle: onboardingSubtitle3,
              ),
              GuidePage(
                size: size,
                image: guide3,
                title: onboardingTitle4,
                subtitle: onboardingSubtitle4,
              ),
            ],
          ),

          /// Skip Button
          Obx(() => controller.currentPageIndex.value == 3
              ? Container()
              : OnboardingSkip()),

          /// Dot Navigation SmoothingIndicator
          const OnboardingDotNavigation(),

          /// Circular Button
          const OnboardingNextButton()
        ],
      ),
    );
  }
}

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
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
                ? Text("LET'S GO!",
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: pureWhite))
                : Icon(Icons.keyboard_arrow_right_rounded),
          ),
        ));
  }
}

class OnboardingDotNavigation extends StatelessWidget {
  const OnboardingDotNavigation({
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

class OnboardingSkip extends StatelessWidget {
  const OnboardingSkip({
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

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
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
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Image(image: AssetImage(image))
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
            style:
                GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Image(
              width: size.width * 0.8,
              height: size.width * 0.8,
              image: AssetImage(image)),
        ],
      ),
    );
  }
}
