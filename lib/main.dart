import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kemsu_app/UI/views/profile/profile_view.dart';
import 'UI/DarkTheme.dart';
import 'UI/splash_screen.dart';
import 'UI/views/news/news_view.dart';
import 'UI/views/profile/profile_viewmodel.dart';
import 'UI/views/schedule/schedule2.0_view.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: !ProfileViewModel(context).darkTheme == true
          ? lightThemeProperties
          : darkThemeProperties,
      routes: {
        '/first': (context) => const NewsView(),
        '/second': (context) => const ProfileView(),
        '/third': (context) => const NewScheduleView(),
      },
      debugShowCheckedModeBanner: false,
      home: const LoadingView(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
