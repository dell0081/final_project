/// Name: Khushpreet Kaur
/// Assignment: Final Project
/// Subject: CST2335
/// Description: It is my own original work free from Plagiarism.

library;

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/Customer/app_localizations.dart';
import 'package:final_project/Customer/customer_dao.dart';
import 'package:final_project/Customer/customer_database.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'customer.dart';

class CustomerListPage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const CustomerListPage({super.key, required this.onLocaleChange});

  @override
  State<CustomerListPage> createState() {
    return CustomerListPageState();
  }
}

class CustomerListPageState extends State<CustomerListPage> {
  final Locale englishLocale = const Locale("en", "CA");
  final Locale frenchLocale = const Locale("fr", "FR");


  var customers = <Customer>[];
  final TextEditingController _customersFirstNameController = TextEditingController();
  final TextEditingController _customersLastNameController = TextEditingController();
  final TextEditingController _customersAddressController = TextEditingController();
  final TextEditingController _customersBirthdayController = TextEditingController();
  var controllers = <TextEditingController>[];
  var names = <String>[];
  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
  bool previous = false;
  bool updated = false;
  int updateId = 0;
  Customer? selected;

///Method to change the language of the app.
  void changeLanguage(Locale newLocale) {
    // setState(() {
    //   _locale = newLocale;
    // });
    widget.onLocaleChange(newLocale);
  }
/// Method to clear all text fields.
  void clearAll() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      updated = false;
    });
  }
  /// Method to check if the device is in landscape mode.
  bool landscape() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return (width > height) && (width > 720);
  }
  /// Method to translate a word using the app's localization.
  String translate(String word) {
    return AppLocalizations.of(context)?.translate(word) ?? 'Hello';
  }
  /// Method to display previously stored data in text fields.
  Future<void> displayPrevious() async {
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].text = await prefs.getString(names[i]);
    }

    display();
  }
  /// Method to display a date picker dialog and return the selected date.
  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }
  /// Method to add a new customer or update an existing customer.
  Future<void> addAndUpdate(Customer customer) async {
    await myDAO.insertCustomer(customer);
    display();
    clearAll();
    setState(() {
      previous = true;
    });
  }

  late CustomerDAO myDAO;
  /// Method to check the highest existing customer ID and return the next ID.
  Future<int> checkId() async {
    int maxId = customers.isNotEmpty ? customers.map((customer) => customer.id).reduce(max) : 0;

    return maxId + 1;
  }

  Future<void> display() async {
    final customerList = await myDAO.getAllCustomers();
    setState(() {
      customers = customerList;
    });
  }
  /// Method to add a new customer.
  Future<void> add(String firstName, String lastName, String address, String birthday) async {
    int id = await checkId();

    final customer = Customer(id, firstName, lastName, address, birthday);
    await addAndUpdate(customer);
  }

  /// Method to display a snack bar when input fields are empty.
  void emptyInputSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('All information should be provided'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  /// Method to delete a customer by ID.
  Future<void> delete(int id) async {
    final temp = await myDAO.getCustomer(id).first;
    if (temp != null) {
      await myDAO.deleteCustomer(temp);
      clearAll();
      display();
    }
  }
  /// Method to prepare a customer for updating.
  Future<void> update1(Customer customer) async {
    setState(() {
      updated = true;
      updateId = customer.id;
      selected = customer;
      _customersFirstNameController.text = customer.firstName;
      _customersLastNameController.text = customer.lastName;
      _customersBirthdayController.text = customer.birthday;
      _customersAddressController.text = customer.address;
    });
  }
  /// Method to update a customer in the database.
  Future<void> update2(Customer customer) async {
    await myDAO.updateCustomer(customer);
    display();
  }
  /// Method to display an alert dialog for confirming customer deletion.
  void displayAlert(Customer customer) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: translate('delete'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Highlight color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Name:'),
                      Text('Last Name:'),
                      Text('Birthday:'),
                      Text('Address:'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.firstName),
                      Text(customer.lastName),
                      Text(customer.birthday),
                      Text(customer.address),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          /// Delete Button
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              delete(customer.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  /// Method to display a help dialog.
  void displayHelp() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: translate('helpTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Highlight color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(30.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  const Text('+', style: TextStyle(fontSize: 15)),
                  Text(translate('add'), style: const TextStyle(fontSize: 12)),
                ]),
                TableRow(children: [
                  const Icon(Icons.clear),
                  Text(translate('clear'), style: const TextStyle(fontSize: 12)),
                ]),
                TableRow(children: [
                  const Icon(Icons.arrow_back),
                  Text(translate('previous'), style: const TextStyle(fontSize: 12)),
                ]),
                TableRow(children: [
                  const Icon(Icons.check_box),
                  Text(translate('update'), style: const TextStyle(fontSize: 12)),
                ]),
                TableRow(children: [
                  const Text('-', style: TextStyle(fontSize: 15)),
                  Text(translate('delete'), style: const TextStyle(fontSize: 12)),
                ]),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  /// Method to display a dialog for changing the language.
  void showChangeLanguage() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: 'Change Language',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Highlight color
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('English'),
            onPressed: () {
              changeLanguage(englishLocale);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('French'),
            onPressed: () {
              changeLanguage(frenchLocale);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //_locale = englishLocale;
    controllers = <TextEditingController>[
      _customersFirstNameController,
      _customersLastNameController,
      _customersAddressController,
      _customersBirthdayController
    ];
    names = <String>["FirstName", "LastName", "Address", "Birthday"];

    $FloorCustomerDatabase
        .databaseBuilder('app_database.db')
        .build()
        .then((database) async {
      myDAO = database.customerDao;

      myDAO.getAllCustomers().then((listOfCustomers) {
        setState(() {
          customers = listOfCustomers;
        });
      });
    });
  }

  @override
  void dispose() {
    _customersFirstNameController.dispose();
    _customersLastNameController.dispose();
    _customersAddressController.dispose();
    _customersBirthdayController.dispose();
    super.dispose();
  }

  Widget list() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return GestureDetector(
          child: ListTile(
            leading: updated && customer.id == updateId
                ? const Icon(Icons.star)
                : const Icon(Icons.flutter_dash),
            title: Text('${customer.firstName} ${customer.lastName}'),
          ),
          onTap: () {
            setState(() {
              updated = true;
              updateId = customer.id;
              update1(customer);
            });
          },
        );
      },
    );
  }
  /// Method to build the detail form for customer input.

  Widget details(bool helpB) {
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customersFirstNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: translate('firstName'),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customersLastNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: translate('lastName'),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customersBirthdayController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: translate('birthdate'),
              ),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1967),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _customersBirthdayController.text =
                  '${date.month}-${date.day}-${date.year}';
                }
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customersAddressController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: translate('address'),
              ),
            ),
          ),
        ],
      ),
      buttons(helpB),
    ]);
  }
  /// Method to build the action buttons.
  Widget buttons(bool helpB) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text(
            '+',
            style: TextStyle(fontSize: 25),
          ),
          onPressed: () {
            bool correct = true;

            var values = <String>[];
            for (var i = 0; i < controllers.length; i++) {
              final value = controllers[i].value.text;
              if (value == "") {
                correct = false;
                break;
              }

              values.add(value);
            }
            if (correct) {
              for (var i = 0; i < controllers.length; i++) {
                prefs.setString(names[i], values[i]);
              }

              add(values[0], values[1], values[2], values[3]);
            } else {
              emptyInputSnackBar(context);
            }
          },
        ),
        ElevatedButton(
          child: const Icon(Icons.clear),
          onPressed: () {
            clearAll();
          },
        ),
        if (previous)
          ElevatedButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              displayPrevious();
            },
          ),
        if (updated) ...[
          ElevatedButton(
            child: const Icon(Icons.check_box),
            onPressed: () {
              bool correct = true;
              var values = <String>[];
              for (var i = 0; i < controllers.length; i++) {
                final value = controllers[i].value.text;
                if (value == "") {
                  correct = false;
                  break;
                }

                values.add(value);
              }
              if (correct) {
                final updatedCustomer = Customer(
                    updateId, values[0], values[1], values[2], values[3]);
                update2(updatedCustomer);
              } else {
                emptyInputSnackBar(context);
              }
            },
          ),
          ElevatedButton(
            child: const Text(
              '-',
              style: TextStyle(fontSize: 25),
            ),
            onPressed: () {
              displayAlert(selected!);
            },
          ),
        ],
        if (helpB) helpButton(),
      ],
    );
  }
  /// Method to build the help button.
  Widget helpButton() {
    return ElevatedButton(
      child: const Icon(Icons.help),
      onPressed: () {
        displayHelp();
      },
    );
  }
  /// Method to build the help button row.
  Widget helpButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        helpButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('title') ?? 'Customer List'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showChangeLanguage();
            },
          ),
        ],
      ),
      body: Center(
        child: landscape()
            ? Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: list(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: details(true),
              ),
            ),
          ],
        )
            : Column(
          children: <Widget>[
            Container(
              child: details(false),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                child: list(),
              ),
            ),
            helpButtonRow(),
          ],
        ),
      ),
    );
  }
}
