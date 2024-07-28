import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ReservationDB.dart';
import 'ReservationListPage.dart'; // Import the updated page
import 'app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorReservationDatabase.databaseBuilder('ReservationDB.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final ReservationDatabase database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReservationListPage(database: database),  // Set the new page as the home
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
