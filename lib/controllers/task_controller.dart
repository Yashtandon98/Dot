import 'package:dot/db/db_helper.dart';
import 'package:dot/models/task.dart';
import 'package:dot/ui/home_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dot/services/notification_services.dart';
import 'package:dot/models/globals.dart';

class TaskController extends GetxController{


  @override
  void onReady(){
    super.onReady();
  }

  var taskList = <Task>[].obs;
  var len = 0;
  var formatter = new DateFormat('yyyy-MM-dd');

  Future<int> addTask({Task? task}) async{
    return await DBHelper.insert(task);
  }

  void getTasks(DateTime chDate) async{
    List<Map<String, dynamic>> tasks = await DBHelper.query(formatter.format(chDate));
    taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
    print(taskList);
  }

  void delete(Task task){
    DBHelper.delete(task);
    getTasks(selectedDate);
  }

  void markTaskCompleted(int id) async{
    await DBHelper.update(id);
    getTasks(selectedDate);
  }

  void updateTaskDate(int id, String date, String repeat) async{
    if(repeat == "Daily"){
      DateTime oldDate = DateFormat.yMd().parse(date);
      DateTime updatedDate = oldDate.add(Duration(days: 1));
      String finalDate = DateFormat.yMd().format(updatedDate);
      await DBHelper.updateDate(id, finalDate);
      getTasks(selectedDate);
    }
    else if(repeat =="Weekly"){
      DateTime oldDate = DateFormat.yMd().parse(date);
      DateTime updatedDate = oldDate.add(Duration(days: 7));
      String finalDate = DateFormat.yMd().format(updatedDate);
      await DBHelper.updateDate(id, finalDate);
      getTasks(selectedDate);
    }
    else{
      DateTime oldDate = DateFormat.yMd().parse(date);
      DateTime updatedDate = oldDate.add(Duration(days: 30));
      String finalDate = DateFormat.yMd().format(updatedDate);
      await DBHelper.updateDate(id, finalDate);
      getTasks(selectedDate);
    }
  }
}