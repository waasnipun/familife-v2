import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/helpers/helpers.dart';
import 'package:familife/src/presentation/authentication/validateCode.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  late double width, height;


  TextEditingController phoneController = new TextEditingController();

  isPhoneNoValid(String? phoneNo) {
    if (phoneNo == null) return false;
    if (phoneNo.length == 0 || phoneNo.length>12) {
          return 'phone_verification_error'.tr();
    }
    else if (countryCode=="+94" && !regExpLK.hasMatch(phoneNo)) {
      return 'phone_verification_error'.tr();
    }
    else if (countryCode=="+45" && !regExpDK.hasMatch(phoneNo)) {
      return 'phone_verification_error'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    var authProvider = context.read<AuthenticateProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  width: width,
                  height: height * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/logo/logo.png"),
                          )),
                        ),
                        Text(
                          "Familife",
                          style: AppTheme.logoTitle,
                        ),
                        Text(
                          "login_description",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.normal),
                        ).tr(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: Container(
                    width: width * 0.8,
                    height: height * 0.1,
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
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
                        labelText: "phone_number".tr(),
                        labelStyle: AppTheme.textFieldLabel,
                        prefixStyle: AppTheme.textFieldLabel,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 20.0),
                        ),
                        prefix: Container(
                          width: width * 0.12,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 0.0, right: 0.0),
                                child: Text(countryCode),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 7,
                        ),
                      ),
                      onChanged: (value) {
                        authProvider.setPhoneNumber = countryCode + value;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.01),
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.7,
                    child: Column(
                      children: [
                        Container(
                          width: width * 0.8,
                          height: height * 0.06,
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            child: Text('continue'.tr(),
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal)),
                            color: FamilifeColors.mainBlue,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () async {
                              if (isPhoneNoValid(authProvider.phoneNumber)==null) {
                                //push to mainpahes
                                Navigator.of(context)
                                    .push(pageRoute(ValidateMobileCodePage()));
                              } else {
                                toast(isPhoneNoValid(authProvider.phoneNumber));
                              }
                            },
                          ),
                        ),
                      ],
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
