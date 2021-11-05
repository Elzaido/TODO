import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/component/component.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

// all in one method :
//1. create DB
//2. create Table
//3. open DB
// Then :
// each one need a method :
//4. insert to DB
//5. get from DB
//6. update in DB
//7. delete from DB

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<
      ScaffoldState>(); // cuz i will make some changes in the scaffold by using the key.
  var formKey = GlobalKey<
      FormState>(); // cuz i will make some changes in the form by using the key.
  final titleControl = TextEditingController();
  final timeControl = TextEditingController();
  final dateControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // two points to deal with cubit like it is an object from cubit :
      create: (BuildContext) => AppCubit()..createDB(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertToDBState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        // an object of AppCubit :
        AppCubit c = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(c.title[c.currentPageIndex]),
          ),
          body: state is! AppGetFromDBLoadingState
              ? c.screen[c.currentPageIndex]
              : Center(child: CircularProgressIndicator()),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (c.isBottumSheetShow) {
                  if (formKey.currentState!.validate()) {
                    c.insertToDB(
                      title: titleControl.text,
                      time: timeControl.text,
                      date: dateControl.text,
                    );
                  }
                  // else ( when it closed ) :
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DefaultTextFeild(
                                    controller: titleControl,
                                    label: 'Task Title',
                                    icon: Icon(Icons.title),
                                    textInputType: TextInputType.text,
                                    validate: (String? v) {
                                      if (v!.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    },
                                    ontap: () {},
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  DefaultTextFeild(
                                    controller: timeControl,
                                    textInputType: TextInputType.text,
                                    icon: Icon(Icons.watch_later_outlined),
                                    label: 'Task Time',
                                    validate: (String? v) {
                                      if (v!.isEmpty) {
                                        return 'Time must not be empty';
                                      }
                                      return null;
                                    },
                                    ontap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeControl.text =
                                            value!.format(context).toString();
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  DefaultTextFeild(
                                    ontap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2030-01-01'))
                                          .then((value) {
                                        dateControl.text =
                                            //to use yMMMd() we install a library for Date in pubspec file.
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    validate: (String? v) {
                                      if (v!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                    controller: dateControl,
                                    textInputType: TextInputType.text,
                                    icon: Icon(Icons.date_range_outlined),
                                    label: 'Task Date',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 15.0,
                      )
                      .closed
                      .then((value) {
                    // when closed :
                    c.ChangeBottumSheetShow(isSheet: false);
                  });
                  // when opened :
                  c.ChangeBottumSheetShow(isSheet: true);
                }
              }, // onPressed
              child: c.isBottumSheetShow ? Icon(Icons.add) : Icon(Icons.edit)),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: c.currentPageIndex, // defualt = 0.
              onTap: (index) {
                c.ChangeIndex(index);
                // setState(() {
                //   currentPageIndex =
                //       index; // change the current index to the tapped item index.
                // });
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive), label: 'Archived'),
              ]),
        );
      }),
    );
  }
}
