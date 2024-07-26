/// Name: Khushpreet Kaur
/// Assignment: Final Project
/// Subject: CST2335
/// Description: It is my own original work free from Plagiarism.
import 'package:floor/floor.dart';

import 'customer.dart';

@dao
abstract class CustomerDAO {
  /// Inserts a new customer into the Customer table.
  /// Returns a Future that completes when the operation is done.
  @insert
  Future<void> insertCustomer(Customer cstm); // asynchronous, return a Future

  /// Deletes a customer from the Customer table.
  /// Returns a Future that completes with the number of rows affected.

  @delete
  Future<int> deleteCustomer(Customer cstm);

  /// Updates an existing customer in the Customer table.
  /// Returns a Future that completes with the number of rows affected.
  @update
  Future<int> updateCustomer(Customer cstm);

  /// Retrieves a customer by their ID from the Customer table.
  /// Returns a Stream that emits the customer or null if not found.

  @Query('Select * from customer where id = :id')
  Stream<Customer?> getCustomer(int id);

  /// Retrieves all customers from the Customer table.
  /// Returns a Future that completes with a list of all customers.
  @Query('Select *  from customer')
  Future<List<Customer>> getAllCustomers();
}
