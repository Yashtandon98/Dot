import 'package:dot/db/db_helper.dart';
import 'package:dot/services/theme_services.dart';
import 'package:dot/ui/splash.dart';
import 'package:dot/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? isViewed;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getInt('onBoard');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dot',
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      home: splash()
    );
  }
}
