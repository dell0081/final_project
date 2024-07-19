import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/customer_dao.dart';
import 'package:final_project/customer_database.dart';

import 'package:flutter/material.dart';
import 'dart:math';
import 'customer.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() {
    return CustomerListPageState();
  }
}

class CustomerListPageState extends State<CustomerListPage> {
  var customers = <Customer>[];
  final TextEditingController _customersFirstNameController =
      TextEditingController();
  final TextEditingController _customersLastNameController =
      TextEditingController();
  final TextEditingController _customersAddressController =
      TextEditingController();
  final TextEditingController _customersBirthdayController =
      TextEditingController();
  var controllers = <TextEditingController>[];
  var names = <String>[];
  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
  bool previous = false;
  bool updated = false;
  int updateId = 0;
  Customer? selected;

  void clearAll() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      updated = false;
    });
  }

  Future<void> displayPrevious() async {
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].text = await prefs.getString(names[i]);
    }

    display();
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }

  Future<void> addAndUpdate(Customer customer) async {
    await myDAO.insertCustomer(customer);
    display();
    clearAll();
    setState(() {
      previous = true;
    });
  }

  late CustomerDAO myDAO;

  Future<int> checkId() async {
    int maxId = customers.isNotEmpty
        ? customers.map((customer) => customer.id).reduce(max)
        : 0;

    return maxId + 1;
  }

  Future<void> display() async {
    final customerList = await myDAO.getAllCustomers();
    setState(() {
      customers = customerList;
    });
  }

  Future<void> add(String firstName, String lastName, String address,
      String birthday) async {
    int id = await checkId();

    final customer = Customer(id, firstName, lastName, address, birthday);
    await addAndUpdate(customer);
  }

  void emptyInputSnackBar() {
    final snackBar = SnackBar(
        content: const Text('All information should be provided'),
        action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> delete(int id) async {
    final temp = await myDAO.getCustomer(id).first;
    if (temp != null) {
      await myDAO.deleteCustomer(temp);
      clearAll();
      display();
    }
  }

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

  Future<void> update2(Customer customer) async {
    await myDAO.updateCustomer(customer);
    display();
  }

  void displayAlert(Customer customer) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: 'Delete this customer?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Highlight color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Add some spacing between the title and content
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customersFirstNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add First Name',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add Last Name',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add Birthdate',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add Address',
                    ),
                  ),
                ),
              ],
            ),
            Row(children: [
              ElevatedButton(
                child: const Text('Add'),
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
                    emptyInputSnackBar();
                  }
                },
              ),
              ElevatedButton(
                  child: const Text('Clear'),
                  onPressed: () {
                    clearAll();
                  }),
              if (previous)
                ElevatedButton(
                    child: const Text('Previous'),
                    onPressed: () {
                      displayPrevious();
                    }),
              if (updated) ...[
                ElevatedButton(
                  child: const Text('Update'),
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
                      emptyInputSnackBar();
                    }
                  },
                ),
                ElevatedButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      displayAlert(selected!);
                      // delete(updateId);
                    }),
              ]
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return GestureDetector(
                    child: ListTile(
                      leading: updated && customer.id == updateId
                          ? const Icon(Icons.star)
                          : const Icon(Icons.flutter_dash),
                      title: Text('${customer.firstName} ${customer.lastName}'),
                      // subtitle: Text('Address: ${customer.address}\nBirthday: ${customer.birthday}'),
                    ),
                    onTap: () {
                      setState(() {
                        updated = true;
                        updateId = customer.id;
                        update1(customer);
                        // displayAlert(customer);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
