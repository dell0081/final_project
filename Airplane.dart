import 'package:floor/floor.dart';

@entity
class Airplane {
  @primaryKey
  final int id;
  final String name;
  final int passengers;
  final double speed;
  final double distance;

  Airplane(this.id, this.name, this.passengers, this.speed, this.distance);
}