import 'package:familife/src/controllers/dbProvider.dart';
import 'package:familife/src/theme/colors.dart';
import 'package:familife/src/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List _todos = [];
  var dbProvider;
  bool _isCompletedTodosAvailable = false;
  TextEditingController _todoController = new TextEditingController();
  var _data;
  var _selectedFamilyMember = 0;

  @override
  void initState() {
    super.initState();
    dbProvider = context.read<DatabaseProvider>();
    _todos = dbProvider.todos;
    checkinDoneTodos();
  }

  checkinDoneTodos() {
    _isCompletedTodosAvailable = false;
    for (var i in _todos) {
      if (i["isDone"]) {
        setState(() {
          _isCompletedTodosAvailable = true;
        });
      }
    }
  }

  _editTodos(context) {
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
                      controller: _todoController,
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
                        labelText: "todoName".tr(),
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
                      if (_todoController.text.length == 0) {
                        toast("eventNameVlaidationError".tr());
                      } else {
                        Navigator.of(context).pop();
                        var result = await dbProvider.createTodos(
                            _todoController.text,
                            dbProvider.familyMembers[_selectedFamilyMember]);
                        if (result) {
                          setState(() {
                            _todos = dbProvider.todos;
                          });
                        } else {
                          toast("creatingTodoError".tr());
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editTodos(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: width * 0.9,
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: _isCompletedTodosAvailable
                    ? Row(
                        children: [
                          Text(
                            "removeTodoTitle".tr(),
                            style: AppTheme.title,
                          ),
                        ],
                      )
                    : null,
              ),
              Wrap(
                  children: _todos.map<Widget>((e) {
                int index = _todos.indexOf(e);
                if (e["isDone"]) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      width: width * 0.9,
                      height: width * 0.15,
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
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(e["todoTitle"])),
                              Flexible(
                                  child: Text(
                                e["userName"],
                                style:
                                    TextStyle(color: FamilifeColors.lightGrey),
                              ))
                            ],
                          ),
                          leading: RoundCheckBox(
                            onTap: (selected) async {
                              dbProvider.updateTodoStatus(index);
                              setState(() {
                                _todos = dbProvider.todos;
                              });
                              checkinDoneTodos();
                              var result = await dbProvider
                                  .updateTodoStatusDatabaseBackground(index);
                              if (!result) {
                                setState(() {
                                  _todos = dbProvider.todos;
                                });
                                checkinDoneTodos();
                              }
                            },
                            size: 25,
                            isChecked: true,
                            checkedColor: FamilifeColors.mainBlue,
                            uncheckedColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    height: 1.0,
                  );
                }
              }).toList()),
              if (_isCompletedTodosAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Divider(
                    height: 10,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: FamilifeColors.lightGrey.withOpacity(0.3),
                  ),
                ),
              Wrap(
                  children: _todos.map<Widget>((e) {
                int index = _todos.indexOf(e);
                if (!e["isDone"]) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      width: width * 0.9,
                      height: width * 0.15,
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
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(e["todoTitle"])),
                              Flexible(
                                  child: Text(
                                e["userName"],
                                style:
                                    TextStyle(color: FamilifeColors.lightGrey),
                              ))
                            ],
                          ),
                          leading: RoundCheckBox(
                            onTap: (selected) async {
                              dbProvider.updateTodoStatus(index);
                              setState(() {
                                _todos = dbProvider.todos;
                              });
                              checkinDoneTodos();
                              var result = await dbProvider
                                  .updateTodoStatusDatabaseBackground(index);
                              if (!result) {
                                setState(() {
                                  _todos = dbProvider.todos;
                                });
                                checkinDoneTodos();
                              }
                            },
                            size: 25,
                            isChecked: false,
                            checkedColor: FamilifeColors.mainBlue,
                            uncheckedColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    height: 1.0,
                  );
                }
              }).toList()),
            ],
          ),
        ),
      ),
    );
  }
}
