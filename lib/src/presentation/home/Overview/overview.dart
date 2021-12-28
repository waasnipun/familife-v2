import 'package:cached_network_image/cached_network_image.dart';
import 'package:familife/src/controllers/authProvider.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/presentation/home/Chat/chat.dart';
import 'package:familife/src/presentation/home/main/mainPage.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:familife/src/widgets/eventTodayCard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late double width, height;

  DateTime _todayDate = DateTime.now();
  var dbProvider;
  TextEditingController _foodplanController = new TextEditingController();
  var _selectedFamilyMember = 0, _dataFood;
  
  
  List _todayEvents = [];
  bool _isEventAvailable = false;

  @override
  void initState() {
    super.initState();
    dbProvider = context.read<DatabaseProvider>();
    _todayDate =
        DateTime(_todayDate.year, _todayDate.month, _todayDate.day, 0, 0, 0);
    fetchinDate();
  }

  Future fetchinDate() async {
    if (dbProvider.foodplan[_todayDate.toString()] != null) {
      _dataFood = dbProvider.foodplan[_todayDate.toString()];
      _selectedFamilyMember = dbProvider.familyMembers
          .indexWhere((e) => e["userName"] == _dataFood["userName"]);
    }
    for (var e in dbProvider.events) {
      if (e.from.year == _todayDate.year &&
          e.from.month == _todayDate.month &&
          e.from.day == _todayDate.day) {
        _isEventAvailable = true;
        _todayEvents.add(e);
      }
    }
  }

  _updateFoodplan(context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (_dataFood != null) {
      _foodplanController..text = _dataFood["foodName"];
    }
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      enableDrag: true,
      isScrollControlled: true,
      elevation: 1,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: Container(
                    width: width * 0.8,
                    height: height * 0.1,
                    child: TextField(
                      controller: _foodplanController..text,
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
                        labelText: "foodplanName".tr(),
                        labelStyle: AppTheme.textFieldLabel,
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      height: height * 0.1,
                      width: width * 0.6,
                      padding: EdgeInsets.only(top: height * 0.001),
                      child: CupertinoPicker(
                        itemExtent: 30,
                        scrollController: FixedExtentScrollController(
                            initialItem: _selectedFamilyMember),
                        onSelectedItemChanged: (val) {
                          setState(() {
                            _selectedFamilyMember = val;
                          });
                        },
                        children: List<Widget>.generate(
                            dbProvider.familyMembers.length, (int index) {
                          return Center(
                              child: Text(
                            dbProvider.familyMembers[index]["userName"],
                            style: TextStyle(fontSize: 14.0),
                          ));
                        }),
                      )),
                ]),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: width * 0.8,
                  height: height * 0.06,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    child: Text('update'.tr(),
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.normal)),
                    color: FamilifeColors.mainBlue,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () async {
                      if (_foodplanController.text.length == 0) {
                        toast("eventNameVlaidationError".tr());
                      } else {
                        var result = await dbProvider.updateFoodplan(
                            _foodplanController.text,
                            dbProvider.familyMembers[_selectedFamilyMember],
                            _todayDate.toString());
                        Navigator.of(context).pop();
                        if (result) {
                          setState(() {
                            // _isFoodplanPresent = true;
                            _dataFood =
                                dbProvider.foodplan[_todayDate.toString()];
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var dbProvider = context.read<DatabaseProvider>();

    height = size.height;
    width = size.width;

    return Center(
      child: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    dbProvider.setChatOpenStatus = true;
                    Navigator.of(context)
                        .push(pageRoute(ChatPage(room: dbProvider.room)));
                  },
                  child: Container(
                    width: width * 0.9,
                    // height: width * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        "familychat".tr(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      // subtitle: Text(
                      //   "new message",
                      //   style: TextStyle(fontSize: 10.0, color: Colors.black),
                      // ),
                      leading: FaIcon(
                        FontAwesomeIcons.facebookMessenger,
                        size: 20.0,
                        color: Colors.black,
                      ),
                      trailing: FaIcon(
                        FontAwesomeIcons.caretRight,
                        size: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    if (_dataFood != null) {
                      _updateFoodplan(context);
                    } else {
                      Navigator.of(context)
                          .pushReplacement(pageRouteNormal(MainPage(3)));
                    }
                  },
                  child: Container(
                    width: width * 0.9,
                    // height: width * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        dbProvider.foodplan[_todayDate.toString()] != null
                            ? dbProvider.foodplan[_todayDate.toString()]
                                    ["foodName"]
                                .toString()
                            : "noFoodPlanMessage".tr(),
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat.EEEE('da').format(_todayDate),
                        style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                      trailing: FaIcon(
                        FontAwesomeIcons.edit,
                        size: 20.0,
                        color: Colors.black,
                      ),
                      leading:
                          dbProvider.foodplan[_todayDate.toString()] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(25.0),
                                  child: _dataFood["imageUrl"].isNotEmpty
                                      ? CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          imageUrl: _dataFood["imageUrl"],
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : null,
                                )
                              : null,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context)
                        .pushReplacement(pageRouteNormal(MainPage(2)));
                  },
                  child: Container(
                    width: width * 0.9,
                    // height: width * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ListTile(
                        title: Text(
                          "todos".tr(),
                          style: TextStyle(
                              fontSize: 16.0, color: FamilifeColors.mainBlue),
                        ),
                        trailing: Chip(
                          label: Text(
                            dbProvider.undoneTodos.toString(),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: FamilifeColors.mainBlue,
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, left: width * 0.1,bottom: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context)
                        .pushReplacement(pageRouteNormal(MainPage(2)));
                  },
                  child: Container(
                    width: width * 0.9,
                    color: Colors.white,
                    child: Text(
                      "eventsToday".tr(),
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
              ),
              if(_isEventAvailable)
                Wrap(
                    children: _todayEvents.map<Widget>((e) {
                    return SubscriptionDetailBox(
                      color: e.background,
                      startTime: e.from.hour.toString()+" : "+(e.from.minute.toString().length==1?"0"+e.from.minute.toString():e.from.minute.toString()),
                      title: e.eventName,
                      endTime: e.to.hour.toString()+" : "+(e.to.minute.toString().length==1?"0"+e.to.minute.toString():e.to.minute.toString()),
                    );
                }).toList()),
            ],
          ),
        ),
      ),
    );
  }
}
