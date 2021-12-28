import 'package:familife/src/controllers/authProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class Splash extends StatefulWidget {
  bool isSignedIn;
  Splash(this.isSignedIn);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  var authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthenticateProvider>(context, listen: false);
    if (widget.isSignedIn) {
      fetchUID();
    }
  }

  Future fetchUID() async {
    await authProvider.fetchUID();
    authProvider.setLogegdInStatus = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            CupertinoActivityIndicator(radius: 15),
          ],
        ),
      ),
    );
  }
}
