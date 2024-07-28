import 'package:floor/floor.dart';
import 'dart:async';
import 'Airplane.dart';

@dao
abstract class AirplaneDAO {
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> findAllAirplanes();

  @Query('SELECT * FROM Airplane WHERE id = :id')
  Stream<Airplane?> findAirplane(int id);

  @insert
  Future<void> insertAirplane(Airplane a);

  @delete
  Future<void> deleteAirplane(Airplane a);
}