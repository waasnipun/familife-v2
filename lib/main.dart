import 'dart:io';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/presentation/authentication/login.dart';
import 'package:familife/src/presentation/home/main/mainPage.dart';
import 'package:familife/src/services/authentication.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/widgets/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  
  FireBaseAuthentication fb = new FireBaseAuthentication();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  await fb.isSignedIn().then((value) => {
        runApp(OverlaySupport(
          child: EasyLocalization(
              supportedLocales: [Locale('en', 'US'), Locale('da', 'DK')],
              path:
                  'assets/translations', // <-- change the path of the translation files
              fallbackLocale: Locale('da', 'DK'),
              child: MyApp(value)),
        ))
      });
}

class MyApp extends StatefulWidget {
  var isSignedInAndDataAvailability;
  MyApp(this.isSignedInAndDataAvailability);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var authProvider;

  void initState() {
    super.initState();
    requestPermission();
  }

  Future requestPermission() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: false,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: false,
      );
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //load the functions
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthenticateProvider>(
                  create: (_) => AuthenticateProvider()),
              ChangeNotifierProvider<DatabaseProvider>(
                  create: (_) => DatabaseProvider()),
            ],
            child: MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Splash(widget.isSignedInAndDataAvailability["isSignedIn"]),
              debugShowCheckedModeBanner: false,
            ),
          );
        } else {
          return MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthenticateProvider>(
                    create: (_) => AuthenticateProvider()),
                ChangeNotifierProvider<DatabaseProvider>(
                    create: (_) => DatabaseProvider()),
              ],
              child: MaterialApp(
                title: 'Familife',
                theme: AppTheme.familifeTheme,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: widget.isSignedInAndDataAvailability["isSignedIn"]
                    ? widget.isSignedInAndDataAvailability["userDataAvailable"]
                        ? MainPage(0)
                        : LoginPage()
                    : LoginPage(),
              ));
        }
      },
    );
  }
}
