import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Airplane/airplane_list_page.dart';
import 'Customer/customer_list_page.dart';
import 'Reservation/ReservationListPage.dart';
import 'Flight/flights_list_page.dart';
import 'AppLocalizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'CA');

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en', 'CA'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: AppLocalizations.of(context)?.translate('mainPage') ?? 'Main Page',
        changeLanguage: changeLanguage,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Function(Locale) changeLanguage;

  const MyHomePage({super.key, required this.title, required this.changeLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerListPage(onLocaleChange: changeLanguage)),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToCustomerList') ?? 'Go to Customer List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AirplaneListPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToAirplaneList') ?? 'Go to Airplane List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlightsListPage(changeLanguage: changeLanguage)),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToFlightsList') ?? 'Go to Flights List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationListPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToReservation') ?? 'Go to Reservation Page'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: 'Change Language',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Highlight color
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('English'),
            onPressed: () {
              changeLanguage(const Locale('en', 'CA'));
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('French'),
            onPressed: () {
              changeLanguage(const Locale('fr', 'FR'));
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
