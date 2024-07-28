import 'package:flutter/material.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';
import 'ReservationDB.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<StatefulWidget> createState() => ReservationListPageState();
}

class ReservationListPageState extends State<ReservationListPage> {
  Reservation? selected;
  late List<Reservation> reservations = [];
  late ReservationDAO dao;
  late TextEditingController customerIdController;
  late TextEditingController flightIdController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    customerIdController = TextEditingController();
    flightIdController = TextEditingController();
    dateController = TextEditingController();
    createDB();
  }

  Future<void> createDB() async {
    final database = await $FloorReservationDatabase.databaseBuilder('reservation_database.db').build();
    dao = database.reservationDAO;
    load();
  }

  Future<void> load() async {
    final temp = await dao.findAllReservations();
    setState(() {
      reservations = temp.cast<Reservation>();
    });
  }

  Future<void> add(int customerId, int flightId, String date) async {
    int id = await checkId();
    final reservation = Reservation(id, customerId, flightId, date);
    await dao.insertReservation(reservation);
    customerIdController.clear();
    flightIdController.clear();
    dateController.clear();
    load();

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservation Added'),
          content: Text('Reservation with ID $id has been added successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> delete(int id) async {
    final reservationStream = dao.findReservation(id);
    reservationStream.listen((reservation) async {
      if (reservation != null) {
        await dao.deleteReservation(reservation);
        load();
      } else {
        // Optionally handle the case where the reservation was not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation not found.')),
        );
      }
    });
  }

  Future<int> checkId() async {
    List<Reservation> allReservations = (await dao.findAllReservations()).cast<Reservation>();
    int maxId = 0;
    for (Reservation reservation in allReservations) {
      if (reservation.id > maxId) {
        maxId = reservation.id;
      }
    }
    return maxId + 1;
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: const Text(
              '1. Add a reservation by filling in the Customer ID, Flight ID, and Date fields, then click the Add button.\n'
                  '2. View all reservations in the list below.\n'
                  '3. Click on a reservation to see its details.\n'
                  '4. Delete a reservation by clicking the delete icon next to it.\n'
                  '5. The app will save the data securely for your next use.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text('This is the Reservation List Page'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: TextField(
                    controller: customerIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Customer ID",
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: flightIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Flight ID",
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Date (YYYY-MM-DD)",
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    try {
                      int customerId = int.parse(customerIdController.text);
                      int flightId = int.parse(flightIdController.text);
                      String date = dateController.text;
                      add(customerId, flightId, date);
                    } catch (e) {
                      invalidInputSnackBar();
                    }
                  },
                ),
              ],
            ),
            Expanded(child: display()),
          ],
        ),
      ),
    );
  }

  void invalidInputSnackBar() {
    var snackBar = SnackBar(
        content: const Text('Invalid Input! Check Instructions.'),
        action: SnackBarAction(
            label: 'Hide',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget display() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 1, child: listReservations()),
          Expanded(flex: 2, child: listReservationDetails()),
        ],
      );
    } else {
      if (selected == null) {
        return listReservations();
      } else {
        return listReservationDetails();
      }
    }
  }

  Widget listReservations() {
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Reservation ${reservation.id}'),
            ],
          ),
          onTap: () {
            setState(() {
              selected = reservation;
            });
          },
        );
      },
    );
  }

  Widget listReservationDetails() {
    if (selected != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Reservation Details', style: TextStyle(fontSize: 30.0)),
              Text('Customer ID: ${selected!.customerId}', style: const TextStyle(fontSize: 20.0)),
              Text('Flight ID: ${selected!.flightId}', style: const TextStyle(fontSize: 20.0)),
              Text('Date: ${selected!.date}', style: const TextStyle(fontSize: 20.0)),
            ],
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('Are you sure you want to delete this reservation?'),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        setState(() {
                          delete(selected!.id);
                          setState(() {
                            selected = null;
                            load();
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Clear'),
            onPressed: () {
              setState(() {
                selected = null;
              });
            },
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
