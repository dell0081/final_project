import 'package:flutter/material.dart';
import 'ReservationDB.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorReservationDatabase.databaseBuilder('ReservationDB.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final ReservationDatabase database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReservationPage(database),
    );
  }
}

class ReservationPage extends StatefulWidget {
  final ReservationDatabase database;

  ReservationPage(this.database);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<List<Reservation>> _reservations;
  Reservation? _selectedReservation;
  late TextEditingController _customerIdController;
  late TextEditingController _flightIdController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _customerIdController = TextEditingController();
    _flightIdController = TextEditingController();
    _dateController = TextEditingController();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      _reservations = widget.database.reservationDAO.findAllReservations();
    });
  }

  Future<void> _addReservation() async {
    try {
      int customerId = int.parse(_customerIdController.text);
      int flightId = int.parse(_flightIdController.text);
      String date = _dateController.text;
      int id = await _checkId();

      final reservation = Reservation(id, customerId, flightId, date);
      await widget.database.reservationDAO.insertReservation(reservation);

      _customerIdController.clear();
      _flightIdController.clear();
      _dateController.clear();

      _loadReservations();

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reservation Added'),
            content: Text('Reservation with ID $id has been added successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();  // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showInvalidInputSnackBar();
    }
  }


  Future<void> _deleteReservation(int id) async {
    final reservation = await widget.database.reservationDAO.findReservation(id).first;
    if (reservation != null) {
      await widget.database.reservationDAO.deleteReservation(reservation);
      _loadReservations();
    } else {
      _showNotFoundSnackBar();
    }
  }

  Future<int> _checkId() async {
    List<Reservation> allReservations = await widget.database.reservationDAO.findAllReservations();
    int maxId = allReservations.fold(0, (prev, reservation) => reservation.id > prev ? reservation.id : prev);
    return maxId + 1;
  }

  void _showInvalidInputSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid Input! Check Instructions.'),
        action: SnackBarAction(
          label: 'Hide',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showNotFoundSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reservation not found.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation List'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customerIdController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Customer ID',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _flightIdController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Flight ID',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Date (YYYY-MM-DD)',
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addReservation,
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Reservation>>(
                    future: _reservations,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No reservations found.'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final reservation = snapshot.data![index];
                            return ListTile(
                              title: Text('Reservation ID: ${reservation.id}'),
                              subtitle: Text('Customer ID: ${reservation.customerId}, Flight ID: ${reservation.flightId}, Date: ${reservation.date}'),
                              onTap: () {
                                setState(() {
                                  _selectedReservation = reservation;
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),
          Expanded(
            flex: 1,
            child: _selectedReservation != null
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reservation Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Customer ID: ${_selectedReservation!.customerId}', style: TextStyle(fontSize: 18)),
                  Text('Flight ID: ${_selectedReservation!.flightId}', style: TextStyle(fontSize: 18)),
                  Text('Date: ${_selectedReservation!.date}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Reservation'),
                          content: Text('Are you sure you want to delete this reservation?'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deleteReservation(_selectedReservation!.id);
                                setState(() {
                                  _selectedReservation = null;
                                });
                              },
                              child: Text('Yes'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('No'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Delete'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedReservation = null;
                      });
                    },
                    child: Text('Clear'),
                  ),
                ],
              ),
            )
                : Center(child: Text('Select a reservation to see details')),
          ),
        ],
      ),
    );
  }
}
