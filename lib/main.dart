// @dart=2.9
import 'package:cactus_v3/pages/create_new_account_page.dart';
import 'package:cactus_v3/pages/dashboard_page.dart';
import 'package:cactus_v3/pages/help_page.dart';
import 'package:cactus_v3/pages/home_page.dart';
import 'package:cactus_v3/pages/info_page.dart';
import 'package:cactus_v3/pages/login_page.dart';
import 'package:cactus_v3/pages/plant_form_edit_page.dart';
import 'package:cactus_v3/pages/plant_form_page.dart';
import 'package:cactus_v3/pages/plant_info_page.dart';
import 'package:cactus_v3/pages/plant_register_page.dart';
import 'package:cactus_v3/pages/profile_edit_page.dart';
import 'package:cactus_v3/pages/profile_page.dart';
import 'package:cactus_v3/provider/plants_provider.dart';
import 'package:cactus_v3/provider/users_provider.dart';
import 'package:cactus_v3/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.lightGreen,
    ));

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Something went Wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => Users(),
              ),
              ChangeNotifierProvider(
                create: (context) => Plants(),
              ),
            ],
            child: MaterialApp(
                theme: ThemeData(
                  primarySwatch: Colors.lightGreen,
                ),
                initialRoute: AppRoutes.LOGIN,
                debugShowCheckedModeBanner: false,
                routes: {
                  AppRoutes.HOME: (context) => HomePage(),
                  AppRoutes.LOGIN: (context) => LoginPage(),
                  AppRoutes.CREATE_ACCOUNT: (context) => CreateNewAccount(),
                  AppRoutes.PLANT_FORM: (context) => PlantFormPage(),
                  AppRoutes.PLANT_INFO: (context) => PlantInfoPage(),
                  AppRoutes.PLANT_FORM_EDIT: (context) => PlantFormEditPage(),
                  AppRoutes.PLANT_REGISTER: (context) => PlantRegisterPage(),
                  AppRoutes.DASHBOARD: (context) => DashboardPage(),
                  AppRoutes.INFO_PAGE: (context) => InfoPage(),
                  AppRoutes.PROFILE: (context) => ProfilePage(),
                  AppRoutes.PROFILE_EDIT: (context) => ProfileEditPage(),
                  AppRoutes.HELP: (context) => HelpPage(),
                }),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
