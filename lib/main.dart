import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'customer_list_page.dart';
import 'airplane_list_page.dart';
import 'flights_list_page.dart';
import 'reservation_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'AppLocalizations.dart';

/// The main entry point for the application.
void main() {
  runApp(MyApp());
}

/// The root widget of the application.
///
/// This widget sets up the localization delegates, supported locales, and theme.
/// It also handles language toggling.
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
            changeLanguage: changeLanguage,
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
  final Function(Locale) changeLanguage;

  /// Constructs a [MyHomePage] widget.
  ///
  /// [title] is the title of the home page.
  /// [onLocaleToggle] is the callback function to toggle the language.
  const MyHomePage(
      {super.key, required this.title, required this.changeLanguage});

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
                    builder: (context) => const AirplaneListPage()),
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
