import 'package:dot/db/db_helper.dart';
import 'package:dot/models/task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dot/services/notification_services.dart';

class TaskController extends GetxController{


  @override
  void onReady(){
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async{
    return await DBHelper.insert(task);
  }

  void getTasks() async{
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
  }

  void delete(Task task){
    DBHelper.delete(task);
    getTasks();
  }

  void markTaskCompleted(int id) async{
    await DBHelper.update(id);
    getTasks();
  }
}