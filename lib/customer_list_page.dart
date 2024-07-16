import 'package:final_project/customer_dao.dart';
import 'package:final_project/customer_database.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _customersFirstNameController = TextEditingController();
  final TextEditingController _customersLastNameController = TextEditingController();
  final TextEditingController _customersAddressController = TextEditingController();
  final TextEditingController _customersBirthdayController = TextEditingController();
  late CustomerDAO myDAO;

  @override
  void initState() {
    super.initState();
    $FloorCustomerDatabase.databaseBuilder('app_database.db').build().then((database) async {
      myDAO = database.getDao();

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
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    title: Text('${customer.firstName} ${customer.lastName}'),
                    subtitle: Text('Address: ${customer.address}\nBirthday: ${customer.birthday}'),
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
