import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
import 'Reservation.dart';
import 'ReservationDAO.dart';

part 'ReservationDB.g.dart'; // This is necessary for code generation

@Database(version: 1, entities: [Reservation])
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDAO get reservationDAO;
}