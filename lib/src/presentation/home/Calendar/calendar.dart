import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/helpers/caldendarHelper.dart';
import 'package:familife/src/presentation/home/main/settings.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:familife/src/utils/sharedWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  TextEditingController _eventNameController = new TextEditingController();
  TextEditingController _eventNameShowController = new TextEditingController();
  DateTime today = DateTime.now();
  DateTime _endTime = DateTime.now(), _startTime = DateTime.now();
  var dbProvider;
  var events;

  @override
  void initState() {
    super.initState();
    dbProvider = context.read<DatabaseProvider>();
    _startTime = DateTime(today.year, today.month, today.day, today.hour,
        today.minute, today.second);
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _eventNameController.dispose();
    _eventNameShowController.dispose();
  }

  _eventCreate(context) {
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
                      controller: _eventNameController,
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
                        labelText: "eventName".tr(),
                        labelStyle: AppTheme.textFieldLabel,
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "startTime".tr(),
                      style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: height * 0.15,
                  width: width * 0.6,
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 14,
                          color:Colors.black
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: _startTime,
                        onDateTimeChanged: (value) {
                          _startTime = value;
                        }),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "endTime".tr(),
                      style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: height * 0.15,
                  width: width * 0.6,
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 14,
                          color:Colors.black
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: _endTime,
                        onDateTimeChanged: (value) {
                          _endTime = value;
                        }),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: width * 0.8,
                  height: height * 0.06,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    child: Text('add'.tr(),
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.normal)),
                    color: Colors.black,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () async {
                      if (_eventNameController.text.length == 0) {
                        toast("eventNameVlaidationError".tr());
                      } else {
                        Navigator.of(context).pop();
                        var result = await dbProvider.createAnEvent(
                            _startTime, _endTime, _eventNameController.text);
                        if (result) {
                          _getDataSource();
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

  _eventShow(context, data) {
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
                      controller: _eventNameShowController
                        ..text = data.eventName,
                      style: AppTheme.textField,
                      enabled: false,
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
                        labelText: "eventName".tr(),
                        labelStyle: AppTheme.textFieldLabel,
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "startTime".tr(),
                      style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: height * 0.15,
                  width: width * 0.6,
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 14,
                          color:Colors.black
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: data.from,
                        onDateTimeChanged: (value) {}),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "endTime".tr(),
                      style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  height: height * 0.15,
                  width: width * 0.6,
                  padding: EdgeInsets.only(top: height * 0.001),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 14,
                          color:Colors.black
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: data.to,
                        onDateTimeChanged: (value) {}),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: width * 0.8,
                  height: height * 0.06,
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    child: Text('remove'.tr(),
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.normal)),
                    color: Colors.red,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () async {
                      showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                                title: Text("removeEvent".tr()),
                                content: Text('removeEventDescription'.tr()),
                                actions: [
                                  // Close the dialog
                                  CupertinoButton(
                                      child: Text('No'.tr()),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                  CupertinoButton(
                                    child: Text('Yes'.tr()),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      var result =
                                          await dbProvider.deleteAnEvent(
                                              data.from,
                                              data.to,
                                              data.eventName);
                                      if (result) {
                                        Navigator.of(context).pop();
                                        _getDataSource();
                                      }
                                    },
                                  )
                                ],
                              ));
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
        appBar: PreferredSize(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 10.0, bottom: 0.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "events".tr(),
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: FamilifeColors.mainBlue),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size(MediaQuery.of(context).size.width, 150.0),
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            _eventCreate(context);
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, top: height * 0.0),
          child: SfCalendar(
            allowViewNavigation: true,
            view: CalendarView.day,
            // allowedViews: <CalendarView>[
            //   CalendarView.day,
            //   CalendarView.week,
            //   CalendarView.month,
            // ],
            onLongPress: (CalendarLongPressDetails details) {
              var t = details.appointments;
              _eventShow(context, t![0]);
            },
            onTap: (CalendarTapDetails details) {},
            dataSource: MeetingDataSource(_getDataSource()),
            showDatePickerButton: true,
            monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true),
            selectionDecoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: FamilifeColors.mainBlue, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              shape: BoxShape.rectangle,
            ),
            showCurrentTimeIndicator: true,
            onSelectionChanged: (value) {
              _startTime = DateTime(
                  value.date!.year,
                  value.date!.month,
                  value.date!.day,
                  value.date!.hour,
                  value.date!.minute,
                  value.date!.second);
              _endTime = _startTime.add(const Duration(hours: 1));
            },
            headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.left,
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w500)),
          ),
        ));
  }

  List<Meeting> _getDataSource() {
    setState(() {
      events = dbProvider.events;
    });
    return events;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}
