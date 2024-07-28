import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../flights_list_page.dart';
import '../Customer/customer_list_page.dart';
import '../airplane_list_page.dart';
import '../reservation_page.dart';
import 'AppLocalizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale locale = const Locale('en', 'CA');

  void changeLanguage(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'CA')],
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Main Page',
        changeLanguage: changeLanguage,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage(
      {super.key, required this.title, required this.changeLanguage});

  final String title;
  final Function(Locale) changeLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerListPage(onLocaleChange: (Locale ) {  },)),
                );
              },
              child: const Text('Go to Customer List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AirplaneListPage()),
                );
              },
              child: const Text('Go to Airplane List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlightsListPage()),
                );
              },
              child: Text('Go to Flights List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationPage()),
                );
              },
              child: const Text('Go to Reservation Page'),
            ),
            ElevatedButton(
              onPressed: () {
                changeLanguage(const Locale('en', 'CA'));
              },
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                changeLanguage(const Locale('fr', 'FR'));
              },
              child: const Text('French'),
            ),
          ],
        ),
      ),
    );
  }
}
