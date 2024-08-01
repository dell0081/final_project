import 'package:floor/floor.dart';

/// Represents a flight entity in the database.
///
/// This class is annotated with [entity] to indicate that it is a table in the database.
@entity
class Flight {
  /// The primary key of the flight. It is automatically generated.
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// The departure city of the flight.
  final String departureCity;

  /// The destination city of the flight.
  final String destinationCity;

  /// The departure time of the flight.
  final String departureTime;

  /// The arrival time of the flight.
  final String arrivalTime;

  /// Constructs a [Flight] object with the specified details.
  ///
  /// [id] is the primary key and is optional since it is auto-generated.
  /// [departureCity] is the city from which the flight departs.
  /// [destinationCity] is the city to which the flight arrives.
  /// [departureTime] is the time at which the flight departs.
  /// [arrivalTime] is the time at which the flight arrives.
  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });
}