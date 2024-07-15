import 'package:floor/floor.dart';

@entity
class Flight {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  Flight({this.id, required this.departureCity, required this.destinationCity, required this.departureTime, required this.arrivalTime});
}
