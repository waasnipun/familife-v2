import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/presentation/authentication/createFamily.dart';
import 'package:familife/src/presentation/authentication/joinFamily.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class ChooseFamilyJoinCreatPage extends StatefulWidget {
  @override
  _ChooseFamilyJoinCreatPageState createState() =>
      _ChooseFamilyJoinCreatPageState();
}

class _ChooseFamilyJoinCreatPageState extends State<ChooseFamilyJoinCreatPage> {
  late double width, height;

  TextEditingController nameController = new TextEditingController();
  var authProvider;

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
      floatingActionButton: Align(
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
              child: FlatButton(
                child: Text('continue'.tr(),
                    style: TextStyle(
                        fontSize: 17.0, fontWeight: FontWeight.normal)),
                color: FamilifeColors.mainBlue,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: height * 0.1, bottom: height * 0.02),
                  child: Container(
                    width: width,
                    height: height * 0.1,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "signup".tr(),
                            style: AppTheme.logoTitle,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            "chooseOrJoinFamily".tr(),
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
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(pageRoute(CreateFamilyPage()));
                          },
                          child: Container(
                            width: width * 0.4,
                            height: height * 0.1,
                            child: Transform.scale(
                              scale: 2,
                              child: SvgPicture.asset(
                                'assets/images/elements/createFamily.svg',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(pageRoute(JoinFamilyPage()));
                          },
                          child: Container(
                            width: width * 0.4,
                            height: height * 0.1,
                            child: Transform.scale(
                              scale: 2,
                              child: SvgPicture.asset(
                                'assets/images/elements/joinFamily.svg',
                              ),
                            ),
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
