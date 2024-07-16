

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


import 'package:final_project/customer.dart';
import 'package:final_project/customer_dao.dart';

// should be same name as database file
part 'customer_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Customer])
abstract class CustomerDatabase extends FloorDatabase{
// get interface to Database
  CustomerDAO getDao();

}