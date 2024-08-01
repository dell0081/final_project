import 'package:floor/floor.dart';
import 'flight.dart';
import 'flight_dao.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

/// The main database class for the application.
///
/// This class extends [FloorDatabase] and provides access to the DAO (Data Access Object) for the `Flight` entity.
@Database(version: 1, entities: [Flight])
abstract class AppDatabase extends FloorDatabase {
  /// Gets the [FlightDao] which provides access to the `Flight` entity operations.
  FlightDao get flightDao;
}