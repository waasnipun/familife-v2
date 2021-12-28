import 'package:familife/src/services/databaseAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlay_support/overlay_support.dart';

class FireBaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future getUserID() async {
    final user = _auth.currentUser;
    return user!.uid;
  }

  //SignIn
  signIn(AuthCredential authCreds) async {
    await _auth.signInWithCredential(authCreds);
    print("Sign in");
  }

  //sign with otp
  signInWithOTP(smsCode, verId) async {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    return await signIn(authCreds);
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print(e.toString());
      toast(e.toString());
      return false;
    }
  }

  Future isSignedIn() async {
    var user = _auth.currentUser;
    if (user != null) {
      print('--------------------Already Logged In!--------------------');
      DatabaseAuth db = new DatabaseAuth();
      var dataAvailability = await db.checkUserDataAvailability(user.uid);
      return {"isSignedIn":true,"userDataAvailable":dataAvailability};
    } else {
      print('--------------------Already NOT Logged In!--------------------');
      return {"isSignedIn":false,"userDataAvailable":false};
    }
  }
}
