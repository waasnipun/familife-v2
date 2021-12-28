import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodplanPage extends StatefulWidget {
  @override
  _FoodplanPageState createState() => _FoodplanPageState();
}

class _FoodplanPageState extends State<FoodplanPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _todayDate = DateTime.now();
  bool _isFoodplanPresent = false;
  var dbProvider;
  TextEditingController _foodplanController = new TextEditingController();
  var _data;
  var _selectedFamilyMember = 0;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
    dbProvider = context.read<DatabaseProvider>();
    if (dbProvider.foodplan[_selectedDate.toString()] != null) {
      setState(() {
        _isFoodplanPresent = true;
        _data = dbProvider.foodplan[_selectedDate.toString()];
      });
    }
  }

  void _resetSelectedDate() {
    setState(() {
      _selectedDate =
          DateTime(_todayDate.year, _todayDate.month, _todayDate.day, 0, 0, 0);
    });
  }

  _editFoodplan(context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
                      controller: _foodplanController,
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
                        scrollController:
                            FixedExtentScrollController(initialItem: 0),
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
                    child: Text('set'.tr(),
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.normal)),
                    color: Colors.black,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () async {
                      if (_foodplanController.text.length == 0) {
                        toast("eventNameVlaidationError".tr());
                      } else {
                        var result = await dbProvider.foodPlanSet(
                            _foodplanController.text,
                            dbProvider.familyMembers[_selectedFamilyMember],
                            _selectedDate.toString());
                        Navigator.of(context).pop();
                        if (result) {
                          setState(() {
                            _isFoodplanPresent = true;
                            _data =
                                dbProvider.foodplan[_selectedDate.toString()];
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

  _updateFoodplan(context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
                      controller: _foodplanController..text = _data["foodName"],
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
                            _selectedDate.toString());
                        Navigator.of(context).pop();
                        if (result) {
                          setState(() {
                            _isFoodplanPresent = true;
                            _data =
                                dbProvider.foodplan[_selectedDate.toString()];
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1,
        centerTitle: false,
        title: Text(
          'foodplan'.tr(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.calendarAlt,
              size: 20.0,
              color: Colors.black,
            ),
            tooltip: 'Reset date',
            onPressed: () {
              setState(() {
                _resetSelectedDate();
              });
              if (dbProvider.foodplan[_selectedDate.toString()] != null) {
                setState(() {
                  _isFoodplanPresent = true;
                  _data = dbProvider.foodplan[_selectedDate.toString()];
                });
              } else {
                setState(() {
                  _isFoodplanPresent = false;
                });
              }
            },
          ),
        ],
      ),
      floatingActionButton: !_isFoodplanPresent
          ? FloatingActionButton(
              onPressed: () {
                if (!_isFoodplanPresent) {
                  _editFoodplan(context);
                }
              },
              child: _isFoodplanPresent ? Icon(Icons.edit) : Icon(Icons.add),
              backgroundColor: Colors.black,
            )
          : null,
      body: Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0, top: height * 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CalendarTimeline(
              showYears: false,
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(Duration(days: 2)),
              lastDate: DateTime.now().add(Duration(days: 4 * 365)),
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date!;
                });
                if (dbProvider.foodplan[_selectedDate.toString()] != null) {
                  setState(() {
                    _isFoodplanPresent = true;
                    _data = dbProvider.foodplan[_selectedDate.toString()];
                  });
                } else {
                  setState(() {
                    _isFoodplanPresent = false;
                  });
                }
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black38,
              dayNameColor: Colors.white,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: FamilifeColors.mainBlue,
              dotsColor: Colors.transparent,
              selectableDayPredicate: (date) => date.day != 23,
              locale: 'da',
            ),
            SizedBox(height: 20),
            _isFoodplanPresent
                ? Container(
                    width: width * 0.9,
                    height: width * 0.18,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: ListTile(
                              title: Text(
                                "Assigned: ${_data["userName"]}",
                                style: TextStyle(fontSize: 11.0),
                              ),
                              subtitle: Text(
                                _data["foodName"],
                                style: TextStyle(fontSize: 20.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedFamilyMember =
                                      dbProvider.familyMembers.indexWhere((e) =>
                                          e["userName"] == _data["userName"]);
                                });
                                _updateFoodplan(context);
                              },
                            ),
                          ),
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: _data["imageUrl"].isNotEmpty?CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  imageUrl:
                                      _data["imageUrl"],
                                      errorWidget: (context, url, error) => Icon(Icons.error),):null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.transparent,
                  ),
          ],
        ),
      ),
    );
  }
}
