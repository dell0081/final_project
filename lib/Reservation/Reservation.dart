import 'package:floor/floor.dart';

@entity
class Reservation {
  @primaryKey
  final int id;
  final int customerId;
  final int flightId;
  final String date; // Format: YYYY-MM-DD

  Reservation(this.id, this.customerId, this.flightId, this.date);
  // simple constructor
}
