import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/presentation/home/main/mainPage.dart';
import 'package:familife/src/presentation/onboarding/onboarding.dart';
import 'package:familife/src/services/authentication.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ValidateMobileCodePage extends StatefulWidget {
  @override
  _ValidateMobileCodePageState createState() => _ValidateMobileCodePageState();
}

class _ValidateMobileCodePageState extends State<ValidateMobileCodePage> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  bool loading = false;
  String verificationId = "";
  var authProvider;
  FireBaseAuthentication fb = new FireBaseAuthentication();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: FamilifeColors.darkgrey),
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthenticateProvider>(context, listen: false);
    verifyPhone(authProvider.phoneNumber);
  }

  @override
  void dispose() {
    super.dispose();
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
  }

  Future<void> verifyPhone(String phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      setState(() {
        loading = true;
      });
      print("Code verification completed: $phoneNo");
      try {
        fb.signIn(authResult);
        print("LOGIN SUCCESS");
      } catch (e) {
        print(e);
        print("LOGIN FAILED");
      }
      setState(() {
        loading = false;
      });
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      print("Code verification failed: $phoneNo, ${authException.message}");
      toast("codeVerificationFailed".tr() +
          " $phoneNo, ${authException.message}");
    };

    final PhoneCodeSent smsSent = (String verId, [int? forceResend]) {
      print("Code sent: $phoneNo");
      toast("codeSent".tr() + " $phoneNo");
      setState(() {
        verificationId = verId;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      print("Code auto retrieval timeout: $phoneNo");
      setState(() {
        verificationId = verId;
      });
    };

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: const Duration(seconds: 30),
          verificationCompleted: verified,
          verificationFailed: verificationfailed,
          codeSent: smsSent,
          codeAutoRetrievalTimeout: autoTimeout);
    } catch (e) {
      print(e);
    }
  }

  void submitOTP() async {
    String otp = _pinPutController.text;
    if (otp.length == 6) {
      setState(() {
        loading = true;
      });
      try {
        authProvider.setCode = otp;
        await fb.signInWithOTP(otp, verificationId);
        await authProvider.fetchUID();
        var resultUserDetailAvailability =
            await authProvider.checkUserDetailAvailability();
        if (resultUserDetailAvailability) {
          Navigator.of(context).pushReplacement(pageRoute(MainPage(0)));
        } else {
          Navigator.of(context).pushReplacement(pageRoute(Onboarding()));
        }
      } catch (e) {
        print(e);
        toast("loginFailed".tr() + " $e");
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: loading
          ? loadingScreen()
          : Center(
              child: Container(
                height: height,
                width: width,
                child: SingleChildScrollView(
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
                                  image:
                                      AssetImage("assets/images/logo/logo.png"),
                                )),
                              ),
                              Text(
                                "Familife",
                                style: AppTheme.logoTitle,
                              ),
                              Text(
                                "code_verification_description".tr(),
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: height * 0.01, bottom: height * 0.05),
                        child: Container(
                          width: width * 0.7,
                          child: PinPut(
                            fieldsCount: 6,
                            eachFieldHeight: width * 0.1,
                            eachFieldWidth: width * 0.1,
                            textStyle: AppTheme.pinCode,
                            onSubmit: (String pin) => SizedBox(),
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            submittedFieldDecoration:
                                _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            selectedFieldDecoration: _pinPutDecoration,
                            followingFieldDecoration:
                                _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                  color: AppTheme.familifeTheme.primaryColor),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FamilifeColors.mainBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: width * 0.8,
                          height: height * 0.06,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            child: Text("submit".tr()),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: FamilifeColors.mainBlue,
                            textColor: Colors.white,
                            onPressed: () {
                              submitOTP();
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
