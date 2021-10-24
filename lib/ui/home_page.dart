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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  var notifyHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
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
    return Expanded(
      child: Obx((){
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index){
              print(_taskController.taskList.length);
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (){
                            _showBottomSheet(context, _taskController.taskList[index]);
                          },
                          child: TaskTile(_taskController.taskList[index]),
                        )
                      ],
                    ),
                  ),
                )
              );
        });
      }),
    );
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
                  setState(() {
                    Get.back();
                  });
                },
                clr: primaryClr,
                context: context
            ),

            _bottomSheetButton(
                label: "Delete Task",
                onTap: (){
                  setState(() {
                    _taskController.delete(task);
                    _taskController.getTasks();
                    Get.back();
                  });
                },
                clr: Colors.redAccent,
                context: context
            ),
            SizedBox(height: 20,),
            _bottomSheetButton(
                label: "Close",
                onTap: (){
                  setState(() {
                    Get.back();
                  });
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

  _addDateBar(){
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
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
          _selectedDate = date;
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
                Text(DateFormat.yMMMMd().format(_selectedDate),
                  style: subHeadingstyle,
                ),
                Text("Today",
                  style: headingStyle,
                ),
              ],
            ),
          ),
          MyButton(label: "+ Add Task", onTap: ()async{
            await Get.to(AddTaskPage());
            _taskController.getTasks();
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
          notifyHelper.displayNotification(
            title:"Theme Changed",
            body:Get.isDarkMode?"Activated Light Theme":"Activated Dark Theme"
          );
          notifyHelper.scheduledNotification();
        },
        child: Icon(Get.isDarkMode?Icons.wb_sunny_outlined:Icons.nightlight_round,
        size: 20,
          color: Get.isDarkMode? Colors.white: Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage(
            "images/profile.png"
          ),
        ),
        SizedBox(width: 20,)
      ],
    );
  }
}
