import 'package:flutter/material.dart';
import 'flight.dart';
import 'database.dart';
import 'flight_dao.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight added')));
    } else {
      _showErrorDialog('All fields must be filled');
    }
  }

  void _updateFlight() async {
    if (_selectedFlight != null) {
      final updatedFlight = Flight(
        id: _selectedFlight!.id,
        departureCity: _departureCityController.text,
        destinationCity: _destinationCityController.text,
        departureTime: _departureTimeController.text,
        arrivalTime: _arrivalTimeController.text,
      );
      await _flightDao.updateFlight(updatedFlight);
      _loadFlights();
      _clearInputFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight updated')));
    }
  }

  void _deleteFlight() async {
    if (_selectedFlight != null) {
      await _flightDao.deleteFlight(_selectedFlight!);
      _loadFlights();
      _clearInputFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight deleted')));
    }
  }

  void _loadFlights() async {
    final flights = await _flightDao.findAllFlights();
    setState(() {
      _flights.clear();
      _flights.addAll(flights);
    });
  }

  void _editFlight(Flight flight) {
    setState(() {
      _selectedFlight = flight;
      _departureCityController.text = flight.departureCity;
      _destinationCityController.text = flight.destinationCity;
      _departureTimeController.text = flight.departureTime;
      _arrivalTimeController.text = flight.arrivalTime;
    });
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
      body: Column(
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
          _selectedFlight == null
              ? ElevatedButton(
            onPressed: _addFlight,
            child: Text('Add Flight'),
          )
              : Row(
            children: [
              ElevatedButton(
                onPressed: _updateFlight,
                child: Text('Update Flight'),
              ),
              ElevatedButton(
                onPressed: _deleteFlight,
                child: Text('Delete Flight'),
              ),
            ],
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
                    _editFlight(flight);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
