import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'flight.dart';
import 'database.dart';
import 'flight_dao.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// A page that displays the details of a flight and allows for updating or deleting the flight.
///
/// The [FlightDetailsPage] is a stateful widget that accepts a [Flight] object and callback functions
/// for updating and deleting the flight. It also supports language toggling.
class FlightDetailsPage extends StatefulWidget {
  /// The flight object to be displayed and managed.
  final Flight flight;

  /// Callback function to be called when the flight is updated.
  final Function(Flight) onUpdate;

  /// Callback function to be called when the flight is deleted.
  final Function(Flight) onDelete;

  /// Callback function to be called when the language is toggled.
  final VoidCallback onLocaleToggle;

  /// Indicates whether the page is embedded within another page or not.
  final bool isEmbedded;

  /// Constructs a [FlightDetailsPage] widget.
  FlightDetailsPage({
    required this.flight,
    required this.onUpdate,
    required this.onDelete,
    required this.onLocaleToggle,
    this.isEmbedded = false,
  });

  @override
  _FlightDetailsPageState createState() => _FlightDetailsPageState();
}

class _FlightDetailsPageState extends State<FlightDetailsPage> {
  late TextEditingController _departureCityController;
  late TextEditingController _destinationCityController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late FlightDao _flightDao;
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _setupDatabase();
    _loadSavedData();
    _departureCityController = TextEditingController(text: widget.flight.departureCity);
    _destinationCityController = TextEditingController(text: widget.flight.destinationCity);
    _departureTimeController = TextEditingController(text: widget.flight.departureTime);
    _arrivalTimeController = TextEditingController(text: widget.flight.arrivalTime);
  }

  /// Sets up the database by building and getting the [FlightDao].
  void _setupDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _flightDao = database.flightDao;
  }

  /// Updates the flight in the database and calls the [onUpdate] callback.
  void _updateFlight() async {
    final updatedFlight = Flight(
      id: widget.flight.id,
      departureCity: _departureCityController.text,
      destinationCity: _destinationCityController.text,
      departureTime: _departureTimeController.text,
      arrivalTime: _arrivalTimeController.text,
    );
    await _flightDao.updateFlight(updatedFlight);
    _saveData();
    widget.onUpdate(updatedFlight);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.translate('flight_updated') ?? 'error')));
  }

  /// Deletes the flight from the database and calls the [onDelete] callback.
  void _deleteFlight() async {
    await _flightDao.deleteFlight(widget.flight);
    widget.onDelete(widget.flight);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.translate('flight_deleted') ?? 'error')));
  }

  /// Loads saved data from encrypted shared preferences into the text controllers.
  void _loadSavedData() async {
    _departureCityController.text = await _prefs.getString('departureCity') ?? '';
    _destinationCityController.text = await _prefs.getString('destinationCity') ?? '';
    _departureTimeController.text = await _prefs.getString('departureTime') ?? '';
    _arrivalTimeController.text = await _prefs.getString('arrivalTime') ?? '';
  }

  /// Saves data from the text controllers into encrypted shared preferences.
  void _saveData() {
    _prefs.setString('departureCity', _departureCityController.text);
    _prefs.setString('destinationCity', _destinationCityController.text);
    _prefs.setString('departureTime', _departureTimeController.text);
    _prefs.setString('arrivalTime', _arrivalTimeController.text);
  }

  @override
  void didUpdateWidget(covariant FlightDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flight != oldWidget.flight) {
      _departureCityController.text = widget.flight.departureCity;
      _destinationCityController.text = widget.flight.destinationCity;
      _departureTimeController.text = widget.flight.departureTime;
      _arrivalTimeController.text = widget.flight.arrivalTime;
    }
  }

  @override
  void dispose() {
    _departureCityController.dispose();
    _destinationCityController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Text('Flight ID: ${widget.flight.id}'),
        TextField(
          controller: _departureCityController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departure_city') ?? 'error'),
        ),
        TextField(
          controller: _destinationCityController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('destination_city') ?? 'error'),
        ),
        TextField(
          controller: _departureTimeController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departure_time') ?? 'error'),
        ),
        TextField(
          controller: _arrivalTimeController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('arrival_time') ?? 'error'),
        ),
        ElevatedButton(
          onPressed: _updateFlight,
          child: Text(AppLocalizations.of(context)?.translate('update_flight') ?? 'error'),
        ),
        ElevatedButton(
          onPressed: _deleteFlight,
          child: Text(AppLocalizations.of(context)?.translate('delete_flight') ?? 'error'),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.translate('flight_details') ?? 'error'),
          actions: [
            IconButton(
              icon: Icon(Icons.language),
              onPressed: widget.onLocaleToggle,
            ),
          ],
        ),
        body: content,
      );
    }
  }
}
