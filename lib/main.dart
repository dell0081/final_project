import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'customer_list_page.dart';
import 'airplane_list_page.dart';
import 'flights_list_page.dart';
import 'reservation_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The main entry point for the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget sets up the localization delegates, supported locales, and theme.
/// It also handles language toggling.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  /// Toggles the language between English and French.
  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? Locale('fr') : Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        Locale("en"),
        Locale("fr")
      ],
      locale: _locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          final appLocalizations = AppLocalizations.of(context);
          return appLocalizations == null
              ? const Center(child: CircularProgressIndicator())
              : MyHomePage(
            title: appLocalizations.title,
            onLocaleToggle: _toggleLanguage,
          );
        },
      ),
    );
  }
}

/// The home page of the application.
///
/// This widget displays buttons to navigate to different pages and a language toggle button.
class MyHomePage extends StatelessWidget {
  final String title;
  final VoidCallback onLocaleToggle;

  /// Constructs a [MyHomePage] widget.
  ///
  /// [title] is the title of the home page.
  /// [onLocaleToggle] is the callback function to toggle the language.
  const MyHomePage({
    super.key,
    required this.title,
    required this.onLocaleToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: onLocaleToggle,
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
                  MaterialPageRoute(
                    builder: (context) => CustomerListPage(),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.go_to_customer_list_page),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AirplaneListPage(),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.go_to_airplane_list_page),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightsListPage(
                      onLocaleToggle: onLocaleToggle,
                    ),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.go_to_flights_list_page),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationPage(),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.go_to_reservation_page),
            ),
          ],
        ),
      ),
    );
  }
}
