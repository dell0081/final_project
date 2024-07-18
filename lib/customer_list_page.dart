import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/customer_dao.dart';
import 'package:final_project/customer_database.dart';
import 'package:floor/floor.dart';
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


  bool updated = false;
  int updateId = 0;







  void clearAll() {
    for (var controller in controllers) {
      controller.clear();
    }
  }


  Future<void> addAndUpdate(Customer customer) async {
    await myDAO.insertCustomer(customer);
    display();
    clearAll();
    displayAlert(customer);
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
      display();
    }
  }

  Future<void> update1(Customer customer) async {
    setState(() {
      updated = true;
      updateId = customer.id;
      _customersFirstNameController.text = customer.firstName;
      _customersLastNameController.text = customer.lastName;
      _customersBirthdayController.text = customer.birthday;
      _customersAddressController.text = customer.address;
    });

    // final temp = await myDAO.getCustomer(id).first;
    final temp = customer;
    if (temp != null) {
      await myDAO.updateCustomer(temp);
      display();
    }
  }

  Future<void> update2(Customer customer) async {
    setState(() {
          updated = false;
    });

    // final temp = await myDAO.getCustomer(id).first;
    final temp = customer;
    if (temp != null) {
      await myDAO.updateCustomer(temp);
      display();
    }
  }

  void displayAlert(Customer customer) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Added Customer')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('First Name ${customer.firstName}')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Last Name ${customer.lastName}')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Birthday ${customer.birthday}')),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Address ${customer.address}')),
              ]),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Ok'),
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
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    update1(customer);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
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
            updated?
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                bool correct = true;
                EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
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
                  final updatedCustomer = Customer(updateId, values[0], values[1], values[2], values[3]);
                  update2(updatedCustomer);
                } else {
                  emptyInputSnackBar();
                }
              },
            ):
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                bool correct = true;
                EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
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
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return GestureDetector(
                    child: ListTile(
                      title: Text('${customer.firstName} ${customer.lastName}'),
                      subtitle: Text(
                          'Address: ${customer.address}\nBirthday: ${customer.birthday}'),
                    ),
                    onTap: () {
                      setState(() {
                        displayAlert(customer);
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
