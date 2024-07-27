/// Name: Khushpreet Kaur
/// Assignment: Final Project
/// Subject: CST2335
/// Description: It is my own original work free from Plagiarism.
import 'package:floor/floor.dart';

@entity // variable name will be the column name
class Customer {
  /// `autoGenerate: true` ensures that the `id` is automatically generated.
  @PrimaryKey(autoGenerate: true) // unique id
  final int id;
  // firstname column
  final String firstName;

  /// `lastName` will be a column in the `Customer` table representing the last name of the customer
  final String lastName;

  /// `address` will be a column in the `Customer` table representing the address of the customer.
  final String address;

  /// "birthday" will be the column in the Customer Table for representing the birthday of the customer.
  final String birthday;

  /// Constructor to initialize a `Customer` object.
  /// Takes `id`, `firstName`, `lastName`, `address`, and `birthday` as parameters.
  Customer(this.id, this.firstName, this.lastName, this.address, this.birthday);
}
