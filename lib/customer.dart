
import 'package:floor/floor.dart';

@entity // variable name will be the column name
class Customer{

@PrimaryKey(autoGenerate: true)// unique id
  final int id;


  final String firstName;
  final String lastName;
  final String address;
  final String birthday;

  Customer(this.id, this.firstName,this.lastName,this.address,this.birthday);
 }