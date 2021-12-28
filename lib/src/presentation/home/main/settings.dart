import 'package:cached_network_image/cached_network_image.dart';
import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/presentation/authentication/login.dart';
import 'package:familife/src/presentation/home/Chat/chat.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double width, height;
  bool _loading = false, _notificationValue = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var dbProvider = context.read<DatabaseProvider>();
    var authProvider = context.read<AuthenticateProvider>();
    _notificationValue = dbProvider.notificationStatus;
    height = size.height;
    width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _loading
          ? null
          : AppBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              brightness: Brightness.light,
              elevation: 1,
              title: Text(
                'settings'.tr(),
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              backgroundColor: Colors.white,
            ),
      body: _loading
          ? loadingScreen()
          : Container(
              height: height,
              width: width,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          width: width * 0.9,
                          // height: width * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              dbProvider.userName,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            leading: dbProvider.profileImageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        imageUrl: dbProvider.profileImageUrl),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: Container(
                                      color: FamilifeColors.mainBlue,
                                      width: 50,
                                      height: 50,
                                    )),
                            subtitle: Text(
                              dbProvider.phoneNumber,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          width: width * 0.9,
                          // height: width * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              "notifications".tr(),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            leading: FaIcon(
                              FontAwesomeIcons.bell,
                              size: 20.0,
                              color: FamilifeColors.mainBlue,
                            ),
                            trailing: CupertinoSwitch(
                              value: _notificationValue,
                              onChanged: (bool value) async {
                                setState(() {
                                  _notificationValue = value;
                                });
                                await dbProvider
                                    .updateNotificationStatusDatabase(value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          width: width * 0.9,
                          // height: width * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: width * 0.7,
                                  child: ListTile(
                                    title: Text(
                                      "Invitationskode",
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                    subtitle: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(dbProvider.familyCode,
                                              style: TextStyle(
                                                  fontSize: 19.0,
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(new ClipboardData(
                                        text: dbProvider.familyCode));
                                    toast("Invitationskode kopieret");
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.copy,
                                    size: 20.0,
                                    color: FamilifeColors.mainBlue,
                                  ),
                                ),
                                SizedBox(
                                  width: 0.5,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () async {
                          showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                    title: Text("logout".tr()),
                                    content: Text('logoutMessage'.tr()),
                                    actions: [
                                      // Close the dialog
                                      CupertinoButton(
                                          child: Text('close'.tr()),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      CupertinoButton(
                                        child: Text('logout'.tr()),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _loading = true;
                                          });
                                          var result =
                                              await authProvider.signOut();
                                          if (result) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    pageRouteNormal(
                                                        LoginPage()));
                                          } else {
                                            toast("logoutFailed".tr());
                                            setState(() {
                                              _loading = false;
                                            });
                                          }
                                        },
                                      )
                                    ],
                                  ));
                        },
                        child: Container(
                          width: width * 0.9,
                          // height: width * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              "logout".tr(),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            leading: FaIcon(
                              FontAwesomeIcons.signOutAlt,
                              size: 20.0,
                              color: FamilifeColors.mainBlue,
                            ),
                            trailing: FaIcon(
                              FontAwesomeIcons.caretRight,
                              size: 20.0,
                              color: FamilifeColors.mainBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GestureDetector(
                        onTap: () async {
                          showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                    title: Text("deletAccount".tr()),
                                    content: Text("deleteAccountmsg".tr()),
                                    actions: [
                                      CupertinoButton(
                                          child: Text('close'.tr()),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      CupertinoButton(
                                        child: Text('continue'.tr()),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _loading = true;
                                          });
                                          var result =
                                              await dbProvider.leaveFamily();
                                          if (result) {
                                            result =
                                                await authProvider.signOut();
                                            if (result) {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      pageRouteNormal(
                                                          LoginPage()));
                                            } else {
                                              toast("leaveFamilyError".tr());
                                              setState(() {
                                                _loading = false;
                                              });
                                            }
                                          } else {
                                            toast("leaveFamilyError".tr());
                                            setState(() {
                                              _loading = false;
                                            });
                                          }
                                        },
                                      )
                                    ],
                                  ));
                        },
                        child: Container(
                          width: width * 0.9,
                          // height: width * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              "leavefamily".tr(),
                              style:
                                  TextStyle(fontSize: 16.0, color: Colors.red),
                            ),
                            leading: FaIcon(
                              FontAwesomeIcons.signOutAlt,
                              size: 20.0,
                              color: Colors.red,
                            ),
                            trailing: FaIcon(
                              FontAwesomeIcons.caretRight,
                              size: 20.0,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
