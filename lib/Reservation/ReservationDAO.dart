import 'package:floor/floor.dart';
import 'dart:async';
import 'Reservation.dart';

@dao
abstract class ReservationDAO {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> findAllReservations();

  @Query('SELECT * FROM Reservation WHERE id = :id')
  Stream<Reservation?> findReservation(int id);

  @insert
  Future<void> insertReservation(Reservation reservation);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}