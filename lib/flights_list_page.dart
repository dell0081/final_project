import 'package:flutter/material.dart';
import 'flight.dart';
import 'database.dart';
import 'flight_dao.dart';
import 'flight_details_page.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'AppLocalizations.dart';

/// A page that displays a list of flights and allows for adding, updating, and deleting flights.
///
/// The [FlightsListPage] is a stateful widget that interacts with the database to manage flights.
/// It also supports language toggling.
class FlightsListPage extends StatefulWidget {
  /// Callback function to be called when the language is toggled.
  final VoidCallback onLocaleToggle;

  /// Constructs a [FlightsListPage] widget.
  FlightsListPage({required this.onLocaleToggle});

  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  final TextEditingController _departureCityController = TextEditingController();
  final TextEditingController _destinationCityController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final List<Flight> _flights = [];
  Flight? _selectedFlight;
  late FlightDao _flightDao;
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDatabase();
      _loadSavedData();
    });
  }

  /// Sets up the database by building and getting the [FlightDao].
  void _setupDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _flightDao = database.flightDao;
    _loadFlights();
  }

  /// Adds a new flight to the database.
  void _addFlight() async {
    final departureCity = _departureCityController.text;
    final destinationCity = _destinationCityController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (departureCity.isNotEmpty && destinationCity.isNotEmpty && departureTime.isNotEmpty && arrivalTime.isNotEmpty) {
      final newFlight = Flight(
        departureCity: departureCity,
        destinationCity: destinationCity,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
      );
      await _flightDao.insertFlight(newFlight);
      _saveData();
      _loadFlights();
      _clearInputFields();
      _showFlightDetails(newFlight);
    } else {
      _showErrorDialog(AppLocalizations.of(context)?.translate('all_fields_required') ?? 'All fields are required');
    }
  }

  /// Updates an existing flight in the database.
  ///
  /// [flight] is the flight to be updated.
  void _updateFlight(Flight flight) async {
    await _flightDao.updateFlight(flight);
    _saveData();
    _loadFlights();
  }

  /// Deletes a flight from the database.
  ///
  /// [flight] is the flight to be deleted.
  void _deleteFlight(Flight flight) async {
    await _flightDao.deleteFlight(flight);
    _loadFlights();
  }

  /// Loads all flights from the database and updates the state.
  void _loadFlights() async {
    final flights = await _flightDao.findAllFlights();
    setState(() {
      _flights.clear();
      _flights.addAll(flights);
    });
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

  /// Shows the details of a selected flight.
  ///
  /// [flight] is the flight whose details are to be shown.
  void _showFlightDetails(Flight flight) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightDetailsPage(
            flight: flight,
            onUpdate: (updatedFlight) {
              _updateFlight(updatedFlight);
              _loadFlights();
            },
            onDelete: (deletedFlight) {
              _deleteFlight(deletedFlight);
              _loadFlights();
            },
            onLocaleToggle: widget.onLocaleToggle, // Pass the onLocaleToggle function
          ),
        ),
      );
    } else {
      setState(() {
        _selectedFlight = flight;
      });
    }
  }

  /// Clears the input fields.
  void _clearInputFields() {
    _departureCityController.clear();
    _destinationCityController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
    _selectedFlight = null;
  }

  /// Shows an error dialog with the specified message.
  ///
  /// [message] is the error message to be shown in the dialog.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('error') ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('go_to_flights_list_page') ?? 'Flights List Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: widget.onLocaleToggle,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                TextField(
                  controller: _departureCityController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departure_city') ?? 'Departure City'),
                ),
                TextField(
                  controller: _destinationCityController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('destination_city') ?? 'Destination City'),
                ),
                TextField(
                  controller: _departureTimeController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departure_time') ?? 'Departure Time'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      _departureTimeController.text = pickedTime.format(context);
                    }
                  },
                ),
                TextField(
                  controller: _arrivalTimeController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('arrival_time') ?? 'Arrival Time'),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      _arrivalTimeController.text = pickedTime.format(context);
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: _addFlight,
                  child: Text(AppLocalizations.of(context)?.translate('add_flight') ?? 'Add Flight'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _flights.length,
                    itemBuilder: (context, index) {
                      final flight = _flights[index];
                      return ListTile(
                        title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                        subtitle: Text('${AppLocalizations.of(context)?.translate('departure') ?? 'Departure'}: ${flight.departureTime}, ${AppLocalizations.of(context)?.translate('arrival') ?? 'Arrival'}: ${flight.arrivalTime}'),
                        onTap: () {
                          _showFlightDetails(flight);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.landscape)
            Expanded(
              flex: 3,
              child: _selectedFlight != null
                  ? FlightDetailsPage(
                flight: _selectedFlight!,
                onUpdate: (updatedFlight) {
                  setState(() {
                    _selectedFlight = updatedFlight;
                    _updateFlight(updatedFlight);
                    _loadFlights();
                  });
                },
                onDelete: (deletedFlight) {
                  setState(() {
                    _selectedFlight = null;
                    _deleteFlight(deletedFlight);
                    _loadFlights();
                  });
                },
                onLocaleToggle: widget.onLocaleToggle, // Pass the onLocaleToggle function
              )
                  : Center(child: Text(AppLocalizations.of(context)?.translate('use_interface') ?? 'Use Interface')),
            ),
        ],
      ),
    );
  }
}
