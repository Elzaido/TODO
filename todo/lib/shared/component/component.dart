import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/cubit.dart';

// dismissible widget alowes me to swip the record right and left :
Widget DefaultTaskItem(Map task, context) => Dismissible(
      // key here needs a string value :
      key: Key(task['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteFromDB(id: task['id']);
      },
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.blue,
                child: Text(
                  '${task['time']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${task['title']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${task['date']}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context).updateOnDB(
                    status: 'done',
                    id: task['id'],
                  );
                },
                icon: Icon(Icons.done),
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {
                  AppCubit.get(context).updateOnDB(
                    status: 'archived',
                    id: task['id'],
                  );
                },
                icon: Icon(Icons.archive),
                color: Colors.grey[700],
              ),
            ],
          )),
    );

Widget DefaultTextFeild({
  required TextEditingController controller,
  required TextInputType textInputType,
  required Icon icon,
  required String label,
  required String? Function(String? v) validate,
  required Null Function() ontap,
}) =>
    TextFormField(
      validator: validate,
      controller: controller,
      keyboardType: textInputType,
      decoration: InputDecoration(
          prefixIcon: icon,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
      onTap: ontap,
    );

Widget taskBuilder({
  required List<Map> tasks,
}) =>
    tasks.length > 0
        ? ListView.separated(
            itemBuilder: (context, index) {
              return DefaultTaskItem(tasks[index], context);
            },
            separatorBuilder: (context, index) {
              return Container(
                color: Colors.grey[300],
                height: 1,
                width: double.infinity,
              );
            },
            itemCount: tasks.length)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu,
                  color: Colors.grey,
                  size: 100,
                ),
                Text(
                  'No tasks to view .. please insert some tasks',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                )
              ],
            ),
          );
