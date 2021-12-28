import 'dart:io';

import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/presentation/authentication/chooseFamilyType.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class DisplayImagePage extends StatefulWidget {
  @override
  _DisplayImagePageState createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {
  late double width, height;

  TextEditingController nameController = new TextEditingController();
  var authProvider;

  final picker = ImagePicker();
  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      authProvider.setprofileImage = File(pickedFile!.path);
    });
    print(authProvider.profileImage);
  }

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
                onPressed: () {
                  //profile picture made optional
                  // if (authProvider.profileImage == null) {
                  //   toast("ERROR! Please insert a profile image");
                  if (authProvider.userName.length == 0) {
                    toast("enterUserNameError".tr());
                  } else {
                    Navigator.of(context)
                        .push(pageRoute(ChooseFamilyJoinCreatPage()));
                  }
                },
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
                      EdgeInsets.only(top: height * 0.1, bottom: height * 0.04),
                  child: Container(
                    width: width,
                    height: height * 0.15,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "signup".tr(),
                            style: AppTheme.logoTitle,
                          ),
                          SizedBox(height: height * 0.05),
                          Text(
                            "signupDescription".tr(),
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
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: FamilifeColors.mainBlue,
                        child: ClipOval(
                          child: new SizedBox(
                            width: 95.0,
                            height: 95.0,
                            // ignore: unnecessary_null_comparison
                            child: (authProvider.profileImage != null)
                                ? Image.file(
                                    authProvider.profileImage,
                                    fit: BoxFit.fill,
                                  )
                                : Transform.scale(
                                    scale: 0.4,
                                    child: SvgPicture.asset(
                                      'assets/images/elements/Actions Plus.svg',
                                    ),
                                  ),
                          ),
                        ),
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
                        labelText: "yourname".tr(),
                        labelStyle: AppTheme.textFieldLabel,
                      ),
                      onChanged: (value) {
                        authProvider.setUserName = value;
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
