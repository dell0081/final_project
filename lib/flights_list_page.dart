import 'package:flutter/material.dart';
import 'flight.dart';
import 'database.dart';
import 'flight_dao.dart';
import 'flight_details_page.dart';

class FlightsListPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _setupDatabase();
  }

  void _setupDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _flightDao = database.flightDao;
    _loadFlights();
  }

  void _addFlight() async {
    final departureCity = _departureCityController.text;
    final destinationCity = _destinationCityController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (departureCity.isNotEmpty && destinationCity.isNotEmpty && departureTime.isNotEmpty && arrivalTime.isNotEmpty) {
      final newFlight = Flight(departureCity: departureCity, destinationCity: destinationCity, departureTime: departureTime, arrivalTime: arrivalTime);
      await _flightDao.insertFlight(newFlight);
      _loadFlights();
      _clearInputFields();
      _showFlightDetails(newFlight);
    } else {
      _showErrorDialog('All fields must be filled');
    }
  }

  void _updateFlight(Flight flight) async {
    await _flightDao.updateFlight(flight);
    _loadFlights();
  }

  void _deleteFlight(Flight flight) async {
    await _flightDao.deleteFlight(flight);
    _loadFlights();
  }

  void _loadFlights() async {
    final flights = await _flightDao.findAllFlights();
    setState(() {
      _flights.clear();
      _flights.addAll(flights);
    });
  }

  void _showFlightDetails(Flight flight) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlightDetailsPage(
          flight: flight,
          onUpdate: (updatedFlight) {
            _updateFlight(updatedFlight);
            _loadFlights();
          },
          onDelete: (deletedFlight) {
            _deleteFlight(deletedFlight);
            _loadFlights();
          },
        )),
      );
    } else {
      setState(() {
        _selectedFlight = flight;
      });
    }
  }

  void _clearInputFields() {
    _departureCityController.clear();
    _destinationCityController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
    _selectedFlight = null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
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
        title: Text('Flights List'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showErrorDialog('Use this interface to manage flights.');
            },
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
                  decoration: InputDecoration(labelText: 'Departure City'),
                ),
                TextField(
                  controller: _destinationCityController,
                  decoration: InputDecoration(labelText: 'Destination City'),
                ),
                TextField(
                  controller: _departureTimeController,
                  decoration: InputDecoration(labelText: 'Departure Time'),
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
                  decoration: InputDecoration(labelText: 'Arrival Time'),
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
                  child: Text('Add Flight'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _flights.length,
                    itemBuilder: (context, index) {
                      final flight = _flights[index];
                      return ListTile(
                        title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                        subtitle: Text('Departure: ${flight.departureTime}, Arrival: ${flight.arrivalTime}'),
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
              )
                  : Center(child: Text('Select a flight to view details')),
            ),
        ],
      ),
    );
  }
}