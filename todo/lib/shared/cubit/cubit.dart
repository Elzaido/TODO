import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archived/archived.dart';
import 'package:todo/modules/done/done.dart';
import 'package:todo/modules/new/new.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// look look look ... everything changing while i use the app .. i need to but it here in the cubit.

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  // create the object that i will use in each page in my app :
  static AppCubit get(context) => BlocProvider.of(context);

  int currentPageIndex = 0; // for toggling between pages.
  late Database database; // where i want to store data.
  List<Map> NewTasks = [];
  List<Map> DoneTasks = [];
  List<Map> ArchivedTasks = [];

  bool isBottumSheetShow = false; // is button bressed or not.

  List<Widget> screen = [
    newTask(),
    doneTask(),
    archivedTask(),
  ];

  List<String> title = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void ChangeIndex(int index) {
    currentPageIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void ChangeBottumSheetShow({
    required isSheet,
  }) {
    isBottumSheetShow = isSheet;
    emit(AppChangeBottomSheetState());
  }

// AppInitialState >> AppCreateDBState >> onOpen (AppGetFromDBState).
  createDB() {
    openDatabase('todo.db',
        version:
            1, // when we change th structure of my DB we upgrade the version
        onCreate: (database, version) {
      print('DB Created');
      database
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)')
          .then((value) {
        print('Table created');
      }).catchError((error) {
        print('error when creating table ${error.toString()}');
      });
      // onOpen ocures after creating the DB.
    }, onOpen: (database) {
      print('DB Opened');
      // if i want to view the new records without refreshing ... i need to use Block ... and it is so eazy there.
      // get the data by the select queury >> database parameter >> value parameter >> tasks list.
      getFromDB(database);
    }).then((value) {
      // initializing the DB :
      database = value;
      emit(AppCreateDBState());
      throw ('DB Created');
    });
  }

  // Insert some records in a transaction
  insertToDB({
    required String title,
    required String time,
    required String date,
  }) {
    database.transaction((txn) {
      return txn.rawInsert(
          'insert into Tasks (title ,time ,date ,status) VALUES("$title","$time","$date","new")');
    }).then((value) {
      print('$value inserted sucssesfully');
      emit(AppInsertToDBState());
      getFromDB(database);
    }).catchError((error) {
      print('error when inserting data ${error.toString()}');
    });
  }

  void getFromDB(database) {
    //make lists = zero for stop duplication cuz i add when i get :

    NewTasks = [];
    DoneTasks = [];
    ArchivedTasks = [];

    emit(AppGetFromDBLoadingState());

    database.rawQuery('SELECT * FROM Tasks').then((value) {
      value.forEach((elements) {
        if (elements['status'] == 'new') {
          NewTasks.add(elements);
        } else if (elements['status'] == 'done') {
          DoneTasks.add(elements);
        } else {
          ArchivedTasks.add(elements);
        }
      });

      emit(AppGetFromDBState());
    });
  }

  void updateOnDB({required String status, required int id}) async {
    database.rawUpdate('UPDATE Tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getFromDB(database);
      emit(AppUpdateOnDBState());
    });
  }

  void deleteFromDB({required int id}) async {
    database.rawDelete('DELETE FROM Tasks WHERE id = ?', [id]).then((value) {
      getFromDB(database);
      emit(AppDeleteFromDBState());
    });
  }
}
