import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'customer_list_page.dart';
import 'airplane_list_page.dart';
import 'flights_list_page.dart';
import 'reservation_page.dart';
import 'AppLocalizations.dart';

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
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale locale = const Locale('en', 'CA');

  void changeLanguage(Locale newLocale) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        locale = newLocale;
      });
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
      home: Builder(
        builder: (context) {
          final appLocalizations = AppLocalizations.of(context);
          return appLocalizations == null
              ? const Center(child: CircularProgressIndicator())
              : MyHomePage(
            title: "Switch",
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
  const MyHomePage({super.key, required this.title, required this.changeLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => changeLanguage(const Locale('fr', 'FR')),
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
              child: Text(AppLocalizations.of(context)?.translate('goToCustomerList') ?? 'Go to Customer List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AirplaneListPage(),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToAirplaneList') ?? 'Go to Airplane List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightsListPage(
                      onLocaleToggle: () => changeLanguage(const Locale('fr', 'FR')),
                    ),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToFlightsList') ?? 'Go to Flights List Page'),
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
              child: Text(AppLocalizations.of(context)?.translate('goToReservationList') ?? 'Go to Reservation List Page'),
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
