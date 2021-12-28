//fetch the data from this
import 'dart:math';
import 'dart:ui';

import 'package:familife/src/helpers/caldendarHelper.dart';
import 'package:familife/src/helpers/familiyHelper.dart';
import 'package:familife/src/services/authentication.dart';
import 'package:familife/src/services/database.dart';
import 'package:familife/src/services/databaseAuth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:overlay_support/overlay_support.dart';
import 'package:easy_localization/easy_localization.dart';

class DatabaseProvider with ChangeNotifier {
  FireBaseAuthentication fb = new FireBaseAuthentication();
  DatabaseAuth dbAuth = new DatabaseAuth();
  Database db = new Database();

  List<FamilyBox> _families = [];
  String _phoneNumber = "";
  String _userID = "";
  String _profileImageUrl = "";
  String _userName = "";
  String _familyCode = "";
  String _newFamilyCode = "";
  String _newFamilyName = "";
  String _familyName = "";
  List _familyMembers = [];
  bool _notificationStatus = true;
  bool _isChatOn = false;
  late types.Room _room;
  Map<String,dynamic> _foodplan = {};
  List _todos = [];
  List<Meeting> _events = <Meeting>[];
  
  int _undoneTodos = 0;

  String get phoneNumber => _phoneNumber;
  String get userID => _userID;
  String get profileImageUrl => _profileImageUrl;
  String get userName => _userName;
  String get familyCode => _familyCode;
  String get familyName => _familyName;
  bool get notificationStatus => _notificationStatus;
  types.Room get room => _room;
  List<FamilyBox> get families => _families;
  List<Meeting> get events => _events;
  Map<String,dynamic> get foodplan => _foodplan;
  List get familyMembers => _familyMembers;
  List get todos => _todos;
  int get undoneTodos => _undoneTodos;
  bool get isChatOn => _isChatOn;

  set setNewFamilyCode(value) {
    _newFamilyCode = value;
    notifyListeners();
  }
  
  set setChatOpenStatus(value){
    _isChatOn = value;
    print("CHAT status"+_isChatOn.toString());
    notifyListeners();
  }

  Future checkNewFamilyCodeValidity() async {
    var result = await dbAuth.checkFamilyCodeValidity(_newFamilyCode);
    if (result["status"] == "OK") {
      _newFamilyName = result["familyName"];
    }
    notifyListeners();
    return result["status"] == "OK";
  }

  //update the selected family
  familyChoiceSelected(index) async {
    var result =
        await db.updateSelectedFamily(_families[index].familyCode, _userID);
    return result;
  }

  joinFamily() async {
    var familyResult = await db.joinNewFamilyData({
      "newMember": _userID,
      "familyID": _newFamilyCode,
      "familyName": _newFamilyName,
    });
    if (familyResult) {
      familyResult = await db.updateSelectedFamily(_newFamilyCode, _userID);
    }
    return familyResult;
  }

  fetchUserData() async {
    _userID = await fb.getUserID();
    var data = await db.fetchUserAndFamilyData(_userID);
    _familyCode = data["selectedFamily"];
    _room = await db.fetchRoom(_userID, _familyCode); //fetching room for chat
    _phoneNumber = data["phoneNumber"];
    _profileImageUrl = data["imageUrl"];
    _userName = data["firstName"];
    _notificationStatus = data["notificationStatus"];
    _families = [];
    _familyMembers = await db.fetchFamilyData(_familyCode);
    for (var i = 0; i < data["families"].length; i++) {
      var code = data["families"][i].keys.elementAt(0);
      if (code == _familyCode) {
        _familyName = data["families"][i][code];
        _families.add(FamilyBox(
            familyCode: code,
            familyName: data["families"][i][code],
            isSelected: true));
      } else {
        _families.add(FamilyBox(
            familyCode: code,
            familyName: data["families"][i][code],
            isSelected: false));
      }
    }

    //fetching events
    await fetchEvents();
    await fetchFoodplan();
    await fetchTodos();
    await checkUndoneTodos();
    print("__________FETCHED DATA FOR OVERVIEW PAGE______________");
    print(data);
    print('_________________________________________________');
    notifyListeners();
  }

  Future leaveFamily() async {
    var familyCodes = [];
    for (var i in _families) {
      familyCodes.add(i.familyCode);
    }
    var result = await db.leaveFamily(_userID, familyCodes);
    return result;
  }

  ///////////////Event section/////////////////
  Future fetchEvents() async {
    _events = <Meeting>[];
    var eventData = await db.fetchEvent(_familyCode);
    for(var i in eventData){
      int r = i["color"]["R"],g = i["color"]["G"],b = i["color"]["B"];
      _events.add(Meeting(i["eventName"], i["startTime"].toDate(), i["endTime"].toDate(), Color.fromRGBO(r, g, b, 1.0), false));
    }
    notifyListeners();
  }
  Future createAnEvent(startTime,endTime,eventName) async {
    var color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    var result = await db.createEvent({
      "eventName":eventName,
      "startTime":startTime,
      "endTime":endTime,
      "color":{"R":color.red,"G":color.green,"B":color.blue}
    },_familyCode);
    if(result){
      _events.add(Meeting(
        eventName, startTime, endTime, color, false));
    }
    notifyListeners();
    return result;
  }
  Future deleteAnEvent(startTime,endTime,eventName) async{
    var deletingElement = _events.firstWhere((data) => (data.from == startTime && data.to==endTime && data.eventName==eventName));
    int deletingElementIndex = _events.indexOf(deletingElement);
    var result = await db.deleteEvent({
      "eventName":deletingElement.eventName,
      "startTime":deletingElement.from,
      "endTime":deletingElement.to,
      "color":{"R":deletingElement.background.red,"G":deletingElement.background.green,"B":deletingElement.background.blue}
    },_familyCode);
    if(result){
      _events.removeAt(deletingElementIndex);
    }
    notifyListeners();
    return result;
  }
  ///////////////////////////////////
  
  ///foodplan///////////////////////
  Future foodPlanSet(foodname,data,date) async{
    data["foodName"] = foodname;
    var result = await db.createFoodplan({date:data},familyCode);
    _foodplan.addAll({date:data});
    notifyListeners();
    return result;
  }
  Future fetchFoodplan() async {
    _foodplan = {};
    var fetchedFoodPlan = await db.fetchFoodplan(_familyCode);
    for(var i in fetchedFoodPlan){
      _foodplan.addAll(i);
    }
    notifyListeners();
  }
  Future updateFoodplan(foodname,data,date) async{
    data["foodName"] = foodname;
    var result = await db.updateFoodplan({date:data},familyCode,date);
    _foodplan[date] = data;
    notifyListeners();
    return result;
  }
  ///////////////////////////////////
  
  ///Todos section///////////////////
  fetchTodos()async{
    _todos = await db.fetchTodos(_familyCode);
    notifyListeners();
  }
  updateTodoStatus(index){
    _todos[index]["isDone"] = !_todos[index]["isDone"];
    notifyListeners();
  }
  updateTodoStatusDatabaseBackground(index) async{
    await checkUndoneTodos();
    var result = await db.updateTodo(_todos,_familyCode);
    if(!result){
      toast("updatingTodoError".tr());
      _todos[index]["isDone"] = !_todos[index]["isDone"];
    }
    notifyListeners();
    return result;
  }
  createTodos(todoName,selectedMember) async{
    var data = {"todoTitle":todoName, "isDone":false};
    data.addAll(selectedMember);
    var result = db.createTodo(data,familyCode);
    _todos.add(data);
    await checkUndoneTodos();
    notifyListeners();
    return result;
  }
  checkUndoneTodos() async{
    _undoneTodos = 0;
    for(var i in _todos){
      if(!i["isDone"]){
        _undoneTodos++;
      }
    }
    notifyListeners();
  }
  ///////////////////////////
  ///Miscelleous//////////
  updateNotificationStatusDatabase(value) async{
    var result = await db.updateNotificationsdb(value,_userID);
    _notificationStatus = value;
    notifyListeners();
  }
  saveDeviceId()async{
    await db.saveDeviceToken(_userID);
  }

}
