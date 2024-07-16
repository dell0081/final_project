
import 'package:floor/floor.dart';

import 'customer.dart';

@dao
abstract class CustomerDAO{

  @insert
   Future<void> insertCustomer(Customer cstm); // asynchronous, return a Future

  @delete
  Future<int>deleteCustomer(Customer cstm);

  @update
  Future<int> updateCustomer(Customer cstm);

  @Query('Select *  from customer')
  Future<List< Customer > >getAllCustomers();

 }