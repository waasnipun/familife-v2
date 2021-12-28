import 'package:familife/src/presentation/authentication/displayPicturePage.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnbaordingSliderState createState() => _OnbaordingSliderState();
}

class _OnbaordingSliderState extends State<Onboarding> {
  int check = 0;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8, keepPage: true);

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            // bottom: 10,
            // left: dSize.width*0.25,
            child: Padding(
              padding: EdgeInsets.only(top: height * 0.05),
              child: customText(
                text: "Familife",
                size: 30,
                color: Colors.black,
                weight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.1),
            child: PageView(
              controller: pageController,
              reverse: false,
              physics: BouncingScrollPhysics(),
              onPageChanged: (int index) {
                setState(() {
                  check = index;
                });
              },
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        customContainer(
                            height: 340.0,
                            width: 210.0,
                            image: "assets/images/onboard-images/onboard.svg",
                            color: Colors.blue,
                            radius: 20.0),
                        SizedBox(
                          height: 30,
                        ),
                        customText(
                          text: "onBoardPageTitle1".tr(),
                          size: 20,
                          color: Colors.black,
                          weight: FontWeight.w800,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "onBoardPageText1".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: "Gilroy"),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        customContainer(
                            height: 340.0,
                            width: 210.0,
                            image: "assets/images/onboard-images/onboard.svg",
                            color: Colors.blue,
                            radius: 20.0),
                        SizedBox(
                          height: 30,
                        ),
                        customText(
                          text: "onBoardPageTitle2".tr(),
                          size: 20,
                          color: Colors.black,
                          weight: FontWeight.w800,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "onBoardPageText2".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: "Gilroy"),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        customContainer(
                            height: 340.0,
                            width: 210.0,
                            image: "assets/images/onboard-images/onboard.svg",
                            color: Colors.blue,
                            radius: 20.0),
                        SizedBox(
                          height: 30,
                        ),
                        customText(
                          text: "onBoardPageTitle3".tr(),
                          size: 20,
                          color: Colors.black,
                          weight: FontWeight.bold,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "onBoardPageText3".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: "Gilroy"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              // bottom: 10,
              // left: dSize.width*0.25,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 7,
                          width: check == 0 ? 25 : 10,
                          decoration: BoxDecoration(
                              color: check == 0
                                  ? FamilifeColors.mainBlue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 7,
                          width: check == 1 ? 25 : 10,
                          decoration: BoxDecoration(
                              color: check == 1
                                  ? FamilifeColors.mainBlue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 7,
                          width: check == 2 ? 25 : 10,
                          decoration: BoxDecoration(
                              color: check == 2
                                  ? FamilifeColors.mainBlue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.03),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                          // boxShadow: <BoxShadow>[
                          //   BoxShadow(
                          //     color: FamilifeColors.mainBlue.withOpacity(0.4),
                          //     blurRadius: 20,
                          //     offset: Offset(0, 15),
                          //   ),
                          // ],
                        ),
                        width: width * 0.8,
                        height: height * 0.06,
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                          child: Text("next".tr()),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: FamilifeColors.mainBlue,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              check = check + 1;
                            });
                            if (check == 3) {
                              Navigator.of(context)
                                  .pushReplacement(pageRoute(DisplayImagePage()));
                              setState(() {
                                check = 2;
                              });
                            }
                            pageController.animateToPage(
                              check,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOutCirc,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      )),
    );
  }
}
