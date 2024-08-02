import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';
import 'ReservationDB.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReservationListPage extends StatefulWidget {
  late ReservationDatabase database;

  ReservationListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  late Future<List<Reservation>> _reservations;
  Reservation? _selectedReservation;
  late TextEditingController _customerIdController;
  late TextEditingController _flightIdController;
  late TextEditingController _dateController;
  Locale _locale = const Locale('en', 'CA');
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _customerIdController = TextEditingController();
    _flightIdController = TextEditingController();
    _dateController = TextEditingController();
    WidgetsFlutterBinding.ensureInitialized();
    $FloorReservationDatabase.databaseBuilder('ReservationDB.db').build().then((db) async {
      widget.database = db;
      _loadReservations();
    });
    _loadSavedData();
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

      _saveData(customerId.toString(), flightId.toString(), date);

      _loadReservations();

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('reservationAdded') ?? 'Reservation Added'),
            content: Text(AppLocalizations.of(context)!.translate('reservationAddedContent')!.replaceFirst('{id}', id.toString()) ?? 'Reservation with ID {id} has been added successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.translate('ok') ?? 'Ok'),
              ),
            ],
          );
        },
      );
      _showReservationAddedSnackBar();
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
        _showReservationDeletedSnackBar();
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
        content: Text(AppLocalizations.of(context)!.translate('invalidInput') ?? 'Invalid Input! Check Instructions.'),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.translate('clear') ?? 'Clear',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showReservationAddedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate('Addedreservation') ?? 'reservation added.'),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.translate('clear') ?? 'Clear',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showReservationDeletedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate('DeletedReservation') ?? 'reservation deleted.'),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.translate('clear') ?? 'Clear',
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
        content: Text(AppLocalizations.of(context)!.translate('reservationNotFound') ?? 'Reservation not found.'),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? const Locale('fr', 'FR') : const Locale('en', 'CA');
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('rinstructions') ?? 'Instructions'),
        content: Text(AppLocalizations.of(context)!.translate('instructionsContent') ?? 'Instructions Content Here'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.translate('ok') ?? 'Ok'),
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

  Future<void> _saveData(String customerId, String flightId, String date) async {
    await _secureStorage.write(key: 'customerId', value: customerId);
    await _secureStorage.write(key: 'flightId', value: flightId);
    await _secureStorage.write(key: 'date', value: date);
  }

  Future<void> _loadSavedData() async {
    String? customerId = await _secureStorage.read(key: 'customerId');
    String? flightId = await _secureStorage.read(key: 'flightId');
    String? date = await _secureStorage.read(key: 'date');

    setState(() {
      if (customerId != null) _customerIdController.text = customerId;
      if (flightId != null) _flightIdController.text = flightId;
      if (date != null) _dateController.text = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('reservationPage') ?? 'Reservation Page'),
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
          builder: (context) => Column(
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
                          labelText: AppLocalizations.of(context)!.translate('enterCustomerId') ?? 'Enter Customer ID',
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
                          labelText: AppLocalizations.of(context)!.translate('enterFlightId') ?? 'Enter Flight ID',
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
                              labelText: AppLocalizations.of(context)!.translate('enterDate') ?? 'Enter Date (YYYY-MM-DD)',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addReservation,
                      child: Text(AppLocalizations.of(context)!.translate('add') ?? 'Add'),
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
                      return Center(child: Text(AppLocalizations.of(context)!.translate('noReservationsFound') ?? 'No reservations found.'));
                    } else {
                      return isMobile ? _buildMobileLayout(snapshot.data!) : _buildDesktopLayout(snapshot.data!);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(List<Reservation> reservations) {
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return ListTile(
          title: Text('${AppLocalizations.of(context)!.translate('reservation') ?? 'Reservation'} ${reservation.id}'),
          onTap: () {
            setState(() {
              _selectedReservation = reservation;
            });
            _showReservationDetails(context);
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(List<Reservation> reservations) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ListTile(
                title: Text('${AppLocalizations.of(context)!.translate('reservation') ?? 'Reservation'} ${reservation.id}'),
                onTap: () {
                  setState(() {
                    _selectedReservation = reservation;
                  });
                },
              );
            },
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
                  AppLocalizations.of(context)!.translate('reservationDetails') ?? 'Reservation Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('${AppLocalizations.of(context)!.translate('customerId')!.replaceFirst('{customerId}', _selectedReservation!.customerId.toString())}', style: TextStyle(fontSize: 18)),
                Text('${AppLocalizations.of(context)!.translate('flightId')!.replaceFirst('{flightId}', _selectedReservation!.flightId.toString())}', style: TextStyle(fontSize: 18)),
                Text('${AppLocalizations.of(context)!.translate('date')!.replaceFirst('{date}', _selectedReservation!.date)}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.translate('deleteConfirmation') ?? 'Are you sure you want to delete this reservation?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteReservation(_selectedReservation!.id);
                              setState(() {
                                _selectedReservation = null;
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.translate('delete') ?? 'Delete'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.translate('cancel') ?? 'Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.translate('delete') ?? 'Delete'),
                ),
              ],
            ),
          )
              : Center(child: Text(AppLocalizations.of(context)!.translate('previousCustomerInformation') ?? 'Previous Customer Information')),
        ),
      ],
    );
  }

  void _showReservationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('reservationDetails') ?? 'Reservation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppLocalizations.of(context)!.translate('customerId')!.replaceFirst('{customerId}', _selectedReservation!.customerId.toString())}'),
            Text('${AppLocalizations.of(context)!.translate('flightId')!.replaceFirst('{flightId}', _selectedReservation!.flightId.toString())}'),
            Text('${AppLocalizations.of(context)!.translate('date')!.replaceFirst('{date}', _selectedReservation!.date)}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.translate('ok') ?? 'Ok'),
          ),
        ],
      ),
    );
  }
}