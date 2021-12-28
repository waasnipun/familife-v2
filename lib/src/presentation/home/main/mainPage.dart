import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/presentation/home/Calendar/calendar.dart';
import 'package:familife/src/presentation/home/Foodplan/foodplan.dart';
import 'package:familife/src/presentation/home/Overview/overview.dart';
import 'package:familife/src/presentation/home/Todos/todos.dart';
import 'package:familife/src/presentation/home/main/joinFamily.dart';
import 'package:familife/src/presentation/home/main/settings.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class MainPage extends StatefulWidget {
  int index;
  MainPage(this.index);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var dbProvider, authProvider;
  bool _loading = false;
  var bottomBarIndex = 0;
  final List<Widget> pages = [
    OverviewPage(),
    CalendarPage(),
    TodosPage(),
    FoodplanPage(),
  ];

  @override
  void initState() {
    super.initState();
    bottomBarIndex = widget.index;
    fetchMain();
  }

  Future fetchMain() async {
    setState(() {
      _loading = true;
    });
    dbProvider = context.read<DatabaseProvider>();
    await dbProvider.fetchUserData();
    await dbProvider.saveDeviceId();
    if (dbProvider.notificationStatus) {
      print("Yes notifications are on");
      notificationListen();
    }
    dbProvider.setChatOpenStatus = false;
    authProvider = context.read<AuthenticateProvider>();
    setState(() {
      _loading = false;
    });
  }

  Future notificationListen() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.title} ${message.notification!.body}');
        showTopSnackBar(
          context,
          CustomSnackBar.info(
            message: message.notification!.title.toString(),
          ),
        );
      } else {
        print("DO SOMEHING");
      }
    });
  }

  onTapChangeFamily(index, selected) async {
    setState(() {
      _loading = true;
    });
    notificationListen();
    if (!selected) {
      setState(() {
        _loading = false;
      });
      return;
    }
    Navigator.of(context).pushReplacement(pageRouteNormal(MainPage(0)));
    var result = await dbProvider.familyChoiceSelected(index);
    if (!result) {
      toast("errorChagingingFamilies".tr());
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: bottomBarIndex == 2
          ? AppBar(
              brightness: Brightness.light,
              elevation: 1,
              centerTitle: false,
              title: Text(
                'todos'.tr(),
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              backgroundColor: Colors.white,
            )
          : bottomBarIndex == 0
              ? _loading
                  ? null
                  : PreferredSize(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 1.0),
                            blurRadius: 1.0,
                          )
                        ], color: Colors.white),
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, top: 20.0, bottom: 20.0, right: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    enableDrag: true,
                                    elevation: 1,
                                    context: context,
                                    builder: (context) {
                                      // Using Wrap makes the bottom sheet height the height of the content.
                                      // Otherwise, the height will be half the height of the screen.
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30.0),
                                        child: Column(
                                          children: [
                                            Wrap(
                                                children: dbProvider.families
                                                    .map<Widget>((e) {
                                              var index = dbProvider.families
                                                  .indexOf(e);
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0.0, left: 20.0),
                                                child: ListTile(
                                                  leading: RoundCheckBox(
                                                    onTap: (selected) async {
                                                      await onTapChangeFamily(
                                                          index, selected);
                                                    },
                                                    size: 25,
                                                    isChecked: e.isSelected,
                                                    checkedColor:
                                                        FamilifeColors.mainBlue,
                                                    uncheckedColor:
                                                        Colors.yellow,
                                                  ),
                                                  title: Text(e.familyName),
                                                ),
                                              );
                                            }).toList()),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(top: 10.0),
                                              width: width * 0.5,
                                              height: height * 0.06,
                                              // ignore: deprecated_member_use
                                              child: FlatButton(
                                                child: Text(
                                                    'addAnotherFamily'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                                color: FamilifeColors.mainBlue,
                                                textColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      pageRouteNormal(
                                                          JoinAnotherFamilyPage()));
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      dbProvider.familyName,
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    SizedBox(width: width * 0.01),
                                    FaIcon(
                                      FontAwesomeIcons.caretDown,
                                      size: 16.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 30.0,
                                height: 30.0,
                                child: GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(pageRoute(SettingsPage()));
                                    },
                                    child: SvgPicture.asset(
                                      "assets/images/elements/settings.svg",
                                      color: Colors.black,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      preferredSize:
                          Size(MediaQuery.of(context).size.width, 150.0),
                    )
              : null,
      body: _loading ? loadingScreen() : pages[bottomBarIndex],
      bottomNavigationBar: Container(
          child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: BottomNavigationBar(
          showUnselectedLabels: true,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: bottomBarIndex,
          onTap: (index) async {
            setState(() {
              bottomBarIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: bottomBarIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/home.svg",
                        color: FamilifeColors.mainBlue,
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/home.svg",
                      ),
                    ),
              // ignore: deprecated_member_use
              title: customText(
                  color: bottomBarIndex == 0
                      ? FamilifeColors.mainBlue
                      : Colors.grey,
                  text: "overview".tr(),
                  size: 12,
                  weight: FontWeight.normal),
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: bottomBarIndex == 1
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/calendar.svg",
                        color: FamilifeColors.mainBlue,
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/calendar.svg",
                      ),
                    ),
              // ignore: deprecated_member_use
              title: customText(
                  color: bottomBarIndex == 1
                      ? FamilifeColors.mainBlue
                      : Colors.grey,
                  text: "calendar".tr(),
                  size: 12,
                  weight: FontWeight.normal),
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: bottomBarIndex == 2
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/todos.svg",
                        color: FamilifeColors.mainBlue,
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/todos.svg",
                      ),
                    ),
              // ignore: deprecated_member_use
              title: customText(
                  color: bottomBarIndex == 2
                      ? FamilifeColors.mainBlue
                      : Colors.grey,
                  text: "todos".tr(),
                  size: 12,
                  weight: FontWeight.normal),
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: bottomBarIndex == 3
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/foodplan.svg",
                        color: FamilifeColors.mainBlue,
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        "assets/images/bottom_navbar/foodplan.svg",
                      ),
                    ),
              // ignore: deprecated_member_use
              title: customText(
                  color: bottomBarIndex == 3
                      ? FamilifeColors.mainBlue
                      : Colors.grey,
                  text: "foodplan".tr(),
                  size: 12,
                  weight: FontWeight.normal),
              backgroundColor: Colors.white,
            ),
          ],
        ),
      )),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: _loading?loadingScreen(): Container(
  //       color: FamilifeColors.mainBlue,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Center(
  //             child: MaterialButton(
  //               child: Text("Chat"),
  //               onPressed: () {
  //                 Navigator.of(context).push(pageRoute(ChatPage(room: dbProvider.room)));
  //               },
  //             ),
  //           ),
  //           Center(
  //         child: MaterialButton(
  //           child: Text("Signout"),
  //           onPressed: () {
  //             authProvider.signOut();
  //             Navigator.of(context).pushReplacement(pageRoute(LoginPage()));
  //           },
  //         ),
  //       ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
