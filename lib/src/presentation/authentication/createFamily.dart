import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/presentation/home/main/mainPage.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class CreateFamilyPage extends StatefulWidget {
  @override
  _CreateFamilyPageState createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends State<CreateFamilyPage> {
  late double width, height;

  TextEditingController nameController = new TextEditingController();
  var authProvider;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthenticateProvider>();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: loading
          ? Container(color: Colors.transparent)
          : Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width * 0.4,
                    height: height * 0.06,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                        child: Text("back".tr(),
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.normal)),
                        color: Colors.white,
                        textColor: FamilifeColors.mainBlue,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: width * 0.4,
                    height: height * 0.06,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      child: Text('continue'.tr(),
                          style: TextStyle(
                              fontSize: 17.0, fontWeight: FontWeight.normal)),
                      color: FamilifeColors.mainBlue,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {
                        authProvider.setFamilyCode =
                            authProvider.familyCodeGenerated;
                        if (authProvider.familyName.length != 0) {
                          setState(() {
                            loading = true;
                          });
                          await authProvider.saveUserData(true);
                          if (authProvider.isDataSaved) {
                            Navigator.of(context)
                                .pushReplacement(pageRoute(MainPage(0)));
                          } else {
                            toast("savingDataError".tr());
                            setState(() {
                              loading = false;
                            });
                          }
                        } else {
                          toast("familyNameDoesntExistError".tr());
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
      body: loading
          ? loadingScreen()
          : Center(
              child: Container(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: height * 0.1, bottom: height * 0.02),
                        child: Container(
                          width: width,
                          height: height * 0.1,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "createFamily".tr(),
                                  style: AppTheme.logoTitle,
                                ),
                                SizedBox(height: height * 0.01),
                                Text(
                                  "createFamilyDescription".tr(),
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.1),
                        child: Container(
                          width: width * 0.8,
                          height: height * 0.1,
                          child: TextField(
                            controller: nameController,
                            style: AppTheme.textField,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: FamilifeColors.lightGrey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: FamilifeColors.lightGrey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: FamilifeColors.mainBlue),
                              ),
                              labelText: "familyName".tr(),
                              labelStyle: AppTheme.textFieldLabel,
                            ),
                            onChanged: (value) {
                              authProvider.setFamilyName = value;
                            },
                          ),
                        ),
                      ),
                      FamilyCodeTextField(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class FamilyCodeTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var authProvider = context.read<AuthenticateProvider>();
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Container(
        width: width * 0.8,
        height: height * 0.07,
        decoration: new BoxDecoration(
            color: FamilifeColors.lightlightGrey,
            borderRadius: new BorderRadius.circular(10.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    authProvider.familyCodeGenerated.toString(),
                    style: TextStyle(
                        fontSize: 18.0,
                        color: FamilifeColors.mainBlue,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 1.3,
                  child: IconButton(
                    iconSize: 8.0,
                    icon: FaIcon(
                      FontAwesomeIcons.copy,
                      size: 16.0,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(
                          text: authProvider.familyCodeGenerated.toString()));
                      toast("invitaionCopied".tr());
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
