import 'package:floor/floor.dart';
import 'flight.dart';
import 'flight_dao.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [Flight])
abstract class AppDatabase extends FloorDatabase {
  FlightDao get flightDao;
}
