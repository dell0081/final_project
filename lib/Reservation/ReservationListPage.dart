import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';
import 'ReservationDB.dart';
import 'app_localizations.dart';

class ReservationListPage extends StatefulWidget {
  final ReservationDatabase database;

  const ReservationListPage({super.key, required this.database});

  @override
  State<StatefulWidget> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  late Future<List<Reservation>> _reservations;
  Reservation? _selectedReservation;
  late TextEditingController _customerIdController;
  late TextEditingController _flightIdController;
  late TextEditingController _dateController;
  Locale _locale = Locale('en', 'CA');

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
            title: Text(AppLocalizations.of(context).translate('reservationAdded')),
            content: Text(AppLocalizations.of(context).translate('reservationAddedContent').replaceFirst('{id}', id.toString())),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('ok')),
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
    final reservationStream = widget.database.reservationDAO.findReservation(id);
    reservationStream.listen((reservation) async {
      if (reservation != null) {
        await widget.database.reservationDAO.deleteReservation(reservation);
        _loadReservations();
      } else {
        _showNotFoundSnackBar();
      }
    });
  }

  Future<int> _checkId() async {
    List<Reservation> allReservations = await widget.database.reservationDAO.findAllReservations();
    int maxId = allReservations.fold(0, (prev, reservation) => reservation.id > prev ? reservation.id : prev);
    return maxId + 1;
  }

  void _showInvalidInputSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('invalidInput')),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate('clear'),
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
        content: Text(AppLocalizations.of(context).translate('reservationNotFound')),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? Locale('fr', 'FR') : Locale('en', 'CA');
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('Instructions')),
        content: Text(AppLocalizations.of(context).translate('instructionsContent')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).translate('ok')),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Reservation Page')),
        actions: [
          IconButton(
            icon: Icon(Icons.translate),
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showInstructionsDialog,
          ),
        ],
      ),
      body: Localizations.override(
        context: context,
        locale: _locale,
        child: Builder(
          builder: (context) => Row(
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
                                labelText: AppLocalizations.of(context).translate('enterCustomerId'),
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
                                labelText: AppLocalizations.of(context).translate('enterFlightId'),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _dateController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context).translate('enterDate'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addReservation,
                            child: Text(AppLocalizations.of(context).translate('add')),
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
                            return Center(child: Text(AppLocalizations.of(context).translate('noReservationsFound')));
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final reservation = snapshot.data![index];
                                return ListTile(
                                  title: Text('${AppLocalizations.of(context).translate('reservation')} ${reservation.id}'),
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
                        AppLocalizations.of(context).translate('reservationDetails'),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text('${AppLocalizations.of(context).translate('customerId').replaceFirst('{customerId}', _selectedReservation!.customerId.toString())}', style: TextStyle(fontSize: 18)),
                      Text('${AppLocalizations.of(context).translate('flightId').replaceFirst('{flightId}', _selectedReservation!.flightId.toString())}', style: TextStyle(fontSize: 18)),
                      Text('${AppLocalizations.of(context).translate('date').replaceFirst('{date}', _selectedReservation!.date)}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context).translate('deleteConfirmation')),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteReservation(_selectedReservation!.id);
                                    setState(() {
                                      _selectedReservation = null;
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context).translate('delete')),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(AppLocalizations.of(context).translate('cancel')),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context).translate('delete')),
                      ),
                    ],
                  ),
                )
                    : Center(child: Text(AppLocalizations.of(context).translate('previousCustomerInformation'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
