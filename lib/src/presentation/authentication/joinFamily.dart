import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/presentation/home/main/mainPage.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class JoinFamilyPage extends StatefulWidget {
  @override
  _JoinFamilyPageState createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends State<JoinFamilyPage> {
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
                        setState(() {
                          loading = true;
                        });
                        if (nameController.text.length == 0) {
                          setState(() {
                            loading = false;
                          });
                          toast("familyCodeDoesntExist".tr());
                        } else {
                          var result =
                              await authProvider.checkFamilyCodeValidity();
                          if (result) {
                            await authProvider.saveUserData(false);
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
                            setState(() {
                              loading = false;
                            });
                            toast("familyCodeIncorrectError".tr());
                          }
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
                          height: height * 0.2,
                          child: Center(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "welcome".tr() +
                                      "\n" +
                                      authProvider.userName.toString(),
                                  style: AppTheme.logoTitle,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: height * 0.01),
                                Text(
                                  "joinFamilyDescripiton".tr(),
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
                        padding: EdgeInsets.only(top: height * 0.001),
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
                              labelText: "familyCode".tr(),
                              labelStyle: AppTheme.textFieldLabel,
                            ),
                            onChanged: (value) {
                              authProvider.setFamilyCode = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
