import 'package:floor/floor.dart';
import 'flight.dart';

/// Data Access Object (DAO) for the [Flight] entity.
///
/// Provides methods for performing database operations on the `Flight` table.
@dao
abstract class FlightDao {
  /// Retrieves all flights from the database.
  ///
  /// Returns a [Future] that resolves to a list of [Flight] objects.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  /// Inserts a new flight into the database.
  ///
  /// [flight] is the [Flight] object to be inserted.
  /// Returns a [Future] that completes when the operation is done.
  @insert
  Future<void> insertFlight(Flight flight);

  /// Updates an existing flight in the database.
  ///
  /// [flight] is the [Flight] object with updated values.
  /// Returns a [Future] that completes when the operation is done.
  @update
  Future<void> updateFlight(Flight flight);

  /// Deletes a flight from the database.
  ///
  /// [flight] is the [Flight] object to be deleted.
  /// Returns a [Future] that completes when the operation is done.
  @delete
  Future<void> deleteFlight(Flight flight);
}
