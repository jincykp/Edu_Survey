import 'package:edusurvey/data/model/survey_model.dart';
import 'package:edusurvey/data/model/user_model.dart';
import 'package:edusurvey/presentations/views/splash_screen.dart';
import 'package:edusurvey/view_models/survey_provider.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive properly
  await Hive.initFlutter();

  // Register adapter
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SurveyFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edu Survey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
