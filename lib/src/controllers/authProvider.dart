import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familife/src/services/authentication.dart';
import 'package:familife/src/services/databaseAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

//creating a random string for family
var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
var now = new DateTime.now();
Random _rnd = new Random(now.millisecondsSinceEpoch);
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class AuthenticateProvider with ChangeNotifier {
  FireBaseAuthentication fb = new FireBaseAuthentication();
  DatabaseAuth db = new DatabaseAuth();

  bool _isDataSaved = false;
  bool _isLoggedIn = false;
  String _phoneNumber = "";
  String _verificationCode = "";
  String _userID = "";
  bool _isNewUser = false;
  File? _profileImage;
  String _userName = "";
  String _familyCodeGenerate = getRandomString(6);
  String _familyName = "";
  String _familyCode = "";
  String _imageURL = "";
  late types.User _userForChat;
  var _createdAt = DateTime.now();
  late types.Room _room;

  bool get isDataSaved => _isDataSaved;
  bool get isLoggedIn => _isLoggedIn;
  String get phoneNumber => _phoneNumber;
  String get verificationCode => _verificationCode;
  String get USERID => _userID;
  bool get isNewUser => _isNewUser;
  File? get profileImage => _profileImage;
  String get userName => _userName;
  String get familyCodeGenerated => _familyCodeGenerate;
  String get familyName => _familyName;
  String get familyCode => _familyCode;
  types.Room get room => _room;
  String get imageURL => _imageURL;

  set setLogegdInStatus(value) {
    _isLoggedIn = value;
    print("USER LOGGED IN - " + _isLoggedIn.toString());
    notifyListeners();
  }

  set setPhoneNumber(value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set setCode(value) {
    _verificationCode = value;
    notifyListeners();
  }

  set setprofileImage(value) {
    _profileImage = value;
    notifyListeners();
  }

  set setUserName(value) {
    _userName = value;
    notifyListeners();
  }

  set setFamilyName(value) {
    _familyName = value;
    notifyListeners();
  }

  set setFamilyCode(value) {
    _familyCode = value;
    print(value);
    notifyListeners();
  }

  set setIsDataSaved(value) {
    _isDataSaved = value;
    notifyListeners();
  }

  fetchUID() async {
    _userID = await fb.getUserID();
    print(_userID);
    notifyListeners();
  }

  Future saveUserData(createFamily) async {
    var data = {
      "phoneNumber": _phoneNumber,
      "families": [
        {_familyCode: _familyName}
      ],
      "firstName": _userName,
      "selectedFamily": _familyCode,
      "userID": _userID,
      "imageUrl": _profileImage,
      "delete":false,
      "notificationStatus":true,
      'deviceID':''
    };
    var result = await db.saveUserData(data);
    if (result) {
      if (createFamily) {
        _isDataSaved = await createFamilyFunction();
      } else {
        _isDataSaved = await joinFamily();
      }
    } else {
      _isDataSaved = false;
    }
    notifyListeners();
  }

  Future checkUserDetailAvailability() async {
    var result = await db.checkUserDataAvailability(_userID);
    print("USER Data Availability - " + result.toString());
    return result;
  }

  Future checkFamilyCodeValidity() async {
    var result = await db.checkFamilyCodeValidity(_familyCode);
    if (result["status"] == "OK") {
      _familyName = result["familyName"];
    }
    notifyListeners();
    return result["status"] == "OK";
  }

  createFamilyFunction() async {
    var familyResult = await db.createFamilyData({
      "members": [USERID],
      "familyName": _familyName,
      "familyID": _familyCode,
      "todos":[],
      "events":[],
      "foodplan":[]
    });

    //creating a room for chatting
    await creatingUserForChat();
    _room = await FirebaseChatCore.instance
        .createGroupRoom(name: _familyName, users: [_userForChat], familyCode: _familyCode);
    //rooom creating finished

    notifyListeners();
    return familyResult;
  }

  joinFamily() async {
    var familyResult = await db.joinFamilyData({
      "newMember": USERID,
      "familyID": _familyCode,
    });
    return familyResult;
  }

  signOut() async {
    _isLoggedIn = false;
    var result = await fb.signOut();
    return result;
  }

  //this is for chat area
  creatingUserForChat() async{
    var data = await db.fetchUserAndFamilyData(_userID);
    _imageURL = await data["imageUrl"];//PROBLEM OF GETTING IMAGE URL
    _userForChat = types.User(
      createdAt: _createdAt.millisecondsSinceEpoch,
      firstName: _userName,
      id: _userID,
      imageUrl: _imageURL,
      lastName: "",
      lastSeen: null,
      metadata: null,
      role: null,
    );
    notifyListeners();
  }

}
