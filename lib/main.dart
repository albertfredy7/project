import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mao/functions/app_functions.dart';
import 'package:google_mao/view-model/auth/authentication_controller.dart';
import 'package:google_mao/view-model/map/google_map_controller.dart';
import 'package:google_mao/view/auth/phone_number_authentication.dart';
import 'package:google_mao/view/map/order_tracking_page.dart';
import 'package:google_mao/view/splashscreen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GoogleMapProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthneticationController(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        // home: const SampleHomeScreen(),
      ),
    );
  }
}

class SampleHomeScreen extends StatefulWidget {
  const SampleHomeScreen({super.key});

  @override
  State<SampleHomeScreen> createState() => _SampleHomeScreenState();
}

class _SampleHomeScreenState extends State<SampleHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("this is the sample screen"),
      ),
      body: Column(
        children: [
          Text("this is the longitude and latitude data"),
          ElevatedButton(
              onPressed: () async {
                String locationresponseString =
                    await AppApiFunctions.fetchData();
                if (locationresponseString != "errror") {
                  print("not error received");
                  print(locationresponseString);
                }
              },
              child: Text("do the get operation"))
        ],
      ),
    );
  }
}
