
/// Name: Khushpreet Kaur
/// Assignment: Final Project
/// Subject: CST2335
/// Description: It is my own original work free from Plagiarism.
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;


import 'package:final_project/Customer/customer.dart';
import 'package:final_project/Customer/customer_dao.dart';


// The generated code for the database will be part of this file.
part 'customer_database.g.dart'; // the generated code will be there

/// The annotation `@Database` indicates that this class represents the database.
/// `version: 1` specifies the version of the database.
/// `entities: [Customer]` lists the entities that will be part of the database.
@Database(version: 1, entities: [Customer])
abstract class CustomerDatabase extends FloorDatabase{
// get interface to Database
  CustomerDAO get customerDao;

}