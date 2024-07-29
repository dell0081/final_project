import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ReservationDB.dart';
import 'ReservationListPage.dart'; // Import the updated page
import 'app_localizations.dart';

void main() async {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  late ReservationDatabase database;


  MyApp( {super.key});

  @override
  State<StatefulWidget> createState() {
       return MyApp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReservationListPage(),  // Set the new page as the home
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'CA'),
        const Locale('fr', 'FR'),
      ],
    );
  }
}

