import 'package:flutter/material.dart';
import 'package:quiz_app/Class/StartTestArguments.dart';
import 'package:quiz_app/screens/quiz.dart';
import 'package:quiz_app/screens/result.dart';
import 'package:quiz_app/screens/start.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magento 2 Quiz App',
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Color.fromRGBO(37, 44, 74, 1.0),
        primaryColor: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        'start': (context) => Start(),
        'quiz': (context) => Quiz(startValues:StartTestArguments("Backend Developer","30","No"),),
        'result': (context) => Result(),
      },
      home: Start(),
    );
  }
}