import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:dot/controllers/task_controller.dart';
import 'package:dot/models/task.dart';
import 'package:dot/services/notification_services.dart';
import 'package:dot/services/theme_services.dart';
import 'package:dot/ui/add_task_bar.dart';
import 'package:dot/ui/theme.dart';
import 'package:dot/ui/widgets/button.dart';
import 'package:dot/ui/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:dot/models/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TaskController _taskController = Get.put(TaskController());
  //DateTime _selectedDate = DateTime.now();
  var notifyHelper;
  DateTime _startDate = DateTime(2021,1,1);
  DatePickerController dpt = DatePickerController();
  var formatter = new DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      dpt.animateToDate(DateTime.now(), duration: Duration(microseconds: 1), curve: Curves.fastLinearToSlowEaseIn);
      _taskController.getTasks(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(height: 10,),
          _showTasks(),
        ],
      ),
    );
  }

  _showTasks(){
    print('hello');
    return Expanded(
      child: Obx((){
        if((_taskController.taskList.length == 0)){
          return Container(
            height: 250,
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/empty_box.png"),
                  color: Get.isDarkMode? Colors.grey: Colors.grey,
                  height: 200,
                ),
                SizedBox(height: 20,),
                Text("No tasks added for today", style: GoogleFonts.lato(textStyle: TextStyle( color: Get.isDarkMode? Colors.grey: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20)),)
              ],
            ),
          );
        }else{
          return ListView.builder(
              itemCount: _taskController.taskList.length,
              itemBuilder: (_, index){
                Task task = _taskController.taskList[index];
                _notification(task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            InkWell(
                              onTap: (){
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    )
                );
              }
          );
        }
      }),
    );
  }

  _notification(Task task){
    if(task.repeat == 'Daily'){
      DateTime date = DateFormat.jm().parse(task.startTime.toString());
      var myTime = DateFormat("HH:mm").format(date);
      notifyHelper.scheduledDailyNotification(
          int.parse(myTime.toString().split(":")[0]),
          int.parse(myTime.toString().split(":")[1]),
          task
      );
    }
    if(task.repeat == 'Weekly'){
      DateTime date = DateFormat.jm().parse(task.startTime.toString());
      var myTime = DateFormat("HH:mm").format(date);
      notifyHelper.scheduledWeeklyNotification(
          int.parse(myTime.toString().split(":")[0]),
          int.parse(myTime.toString().split(":")[1]),
          task
      );
    }
    if(task.repeat == 'Monthly'){
      DateTime date = DateFormat.jm().parse(task.startTime.toString());
      var myTime = DateFormat("HH:mm").format(date);
      notifyHelper.scheduledMonthlyNotification(
          int.parse(myTime.toString().split(":")[0]),
          int.parse(myTime.toString().split(":")[1]),
          task
      );
    }
    else{
      DateTime date = DateFormat.jm().parse(task.startTime.toString());
      var myTime = DateFormat("HH:mm").format(date);
      notifyHelper.scheduledNotification(
          int.parse(myTime.toString().split(":")[0]),
          int.parse(myTime.toString().split(":")[1]),
          task
      );
    }
  }

  _showBottomSheet(BuildContext, Task task){
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted==1?
            MediaQuery.of(context).size.height*0.24:
            MediaQuery.of(context).size.height*0.32,
        color: Get.isDarkMode? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300],
              ),
            ),
            Spacer(),
            task.isCompleted==1
            ?Container()
                : _bottomSheetButton(
                label: "Task Completed",
                onTap: (){
                  _taskController.markTaskCompleted(task.id!);
                  Get.back();
                },
                clr: primaryClr,
                context: context
            ),

            _bottomSheetButton(
                label: "Delete Task",
                onTap: (){
                  if(task.repeat == 'Monthly' || task.repeat == 'Daily' || task.repeat == 'Weekly'){
                    _showInnerBottomSheet(context, task);
                    //Get.back();
                  }else {
                    _taskController.delete(task);
                    notifyHelper.cancelNotification(task.id);
                    _taskController.getTasks(selectedDate);
                    _taskController.len = _taskController.taskList.length;
                    Get.back();
                  }
                  //Get.back();
                },
                clr: Colors.redAccent,
                context: context
            ),
            SizedBox(height: 20,),
            _bottomSheetButton(
                label: "Close",
                onTap: (){
                  Get.back();
                },
                clr: Colors.white,
                isClose: true,
                context: context
            ),
            SizedBox(height: 10,)
          ],
        ),
      )
    );
  }

  _showInnerBottomSheet(BuildContext, Task task){
    Get.bottomSheet(
        Container(
          padding: const EdgeInsets.only(top: 4),
          height: MediaQuery.of(context).size.height*0.24,
          color: Get.isDarkMode? darkGreyClr : Colors.white,
          child: Column(
            children: [
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300],
                ),
              ),
              Spacer(),
              _bottomInnerSheetButton(
                  label: "Delete Task for Today",
                  onTap: (){
                    _taskController.updateTaskDate(task.id!, task.date!, task.repeat!);
                    _taskController.getTasks(selectedDate);
                    _taskController.len = _taskController.taskList.length;
                    Get.back();
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context
              ),

              _bottomInnerSheetButton(
                  label: "Delete Repeating Task",
                  onTap: (){
                    _taskController.delete(task);
                    notifyHelper.cancelNotification(task.id);
                    _taskController.getTasks(selectedDate);
                    _taskController.len = _taskController.taskList.length;
                    Get.back();
                    Get.back();
                  },
                  clr: Colors.redAccent,
                  context: context
              ),
              SizedBox(height: 20,),
              _bottomInnerSheetButton(
                  label: "Close",
                  onTap: (){
                    Get.back();
                  },
                  clr: Colors.white,
                  isClose: true,
                  context: context
              ),
              SizedBox(height: 10,)
            ],
          ),
        )
    );
  }

  _bottomSheetButton({required String label, required Function()? onTap, required Color clr, bool isClose = false, required context}){
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose==true?Colors.transparent:clr,
        ),
        child: Center(child: Text(label,
          style: isClose?titleStyle:titleStyle.copyWith(color: Colors.white),
        )),
      ),
    );
  }

  _bottomInnerSheetButton({required String label, required Function()? onTap, required Color clr, bool isClose = false, required context}){
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 35,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose == true?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose==true?Colors.transparent:clr,
        ),
        child: Center(child: Text(label,
          style: isClose?titleStyle:titleStyle.copyWith(color: Colors.white),
        )),
      ),
    );
  }

  _addDateBar(){
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        _startDate,
        height: 100,
        width: 80,
        controller: dpt,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        onDateChange: (date){
          setState(() {
            selectedDate = date;
            print(formatter.format(selectedDate));
            _taskController.getTasks(selectedDate);
          });
        },
      ),
    );
  }

  _addTaskBar(){
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingstyle,
                ),
                Text("Today",
                  style: headingStyle,
                ),
              ],
            ),
          ),
          MyButton(label: "+ Add Task", onTap: ()async{
            await Get.to(() => AddTaskPage());
            }
          )
        ],
      ),
    );
  }

  _appBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: InkWell(
        onTap:(){
          ThemeService().switchTheme();
          /*notifyHelper.displayNotification(
            title:"Theme Changed",
            body:Get.isDarkMode?"Activated Light Theme":"Activated Dark Theme"
          );*/
          //notifyHelper.scheduledNotification();
        },
        child: Icon(Get.isDarkMode?Icons.wb_sunny_outlined:Icons.nightlight_round,
        size: 20,
          color: Get.isDarkMode? Colors.white: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () =>{},
          icon: Image.asset("images/logo.png"),
        ),
        SizedBox(width: 20,)
      ],
    );
  }
}