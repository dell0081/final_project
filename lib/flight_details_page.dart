import 'package:flutter/material.dart';
import 'flight.dart';
import 'database.dart';
import 'flight_dao.dart';

class FlightDetailsPage extends StatefulWidget {
  final Flight flight;
  final Function(Flight) onUpdate;
  final Function(Flight) onDelete;
  final bool isEmbedded;

  FlightDetailsPage({
    required this.flight,
    required this.onUpdate,
    required this.onDelete,
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

  @override
  void initState() {
    super.initState();
    _setupDatabase();
    _departureCityController = TextEditingController(text: widget.flight.departureCity);
    _destinationCityController = TextEditingController(text: widget.flight.destinationCity);
    _departureTimeController = TextEditingController(text: widget.flight.departureTime);
    _arrivalTimeController = TextEditingController(text: widget.flight.arrivalTime);
  }

  void _setupDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _flightDao = database.flightDao;
  }

  void _updateFlight() async {
    final updatedFlight = Flight(
      id: widget.flight.id,
      departureCity: _departureCityController.text,
      destinationCity: _destinationCityController.text,
      departureTime: _departureTimeController.text,
      arrivalTime: _arrivalTimeController.text,
    );
    await _flightDao.updateFlight(updatedFlight);
    widget.onUpdate(updatedFlight);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight updated')));
  }

  void _deleteFlight() async {
    await _flightDao.deleteFlight(widget.flight);
    widget.onDelete(widget.flight);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight deleted')));
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
          decoration: InputDecoration(labelText: 'Departure City'),
        ),
        TextField(
          controller: _destinationCityController,
          decoration: InputDecoration(labelText: 'Destination City'),
        ),
        TextField(
          controller: _departureTimeController,
          decoration: InputDecoration(labelText: 'Departure Time'),
        ),
        TextField(
          controller: _arrivalTimeController,
          decoration: InputDecoration(labelText: 'Arrival Time'),
        ),
        ElevatedButton(
          onPressed: _updateFlight,
          child: Text('Update Flight'),
        ),
        ElevatedButton(
          onPressed: _deleteFlight,
          child: Text('Delete Flight'),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Flight Details'),
        ),
        body: content,
      );
    }
  }
}
