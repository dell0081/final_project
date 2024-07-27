import 'package:floor/floor.dart';
import 'flight.dart';

@dao
abstract class FlightDao {
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  @insert
  Future<void> insertFlight(Flight flight);

  @update
  Future<void> updateFlight(Flight flight);

  @delete
  Future<void> deleteFlight(Flight flight);
}
