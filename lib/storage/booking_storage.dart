import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingStorage {
  final FlutterSecureStorage storage;

  BookingStorage({required this.storage});

  // Guardar todas las reservas
  Future<void> saveAllBookings(String bookingsJson) async {
    await storage.write(key: 'bookings', value: bookingsJson);
  }

  // Obtener todas las reservas
  Future<String?> getAllBookings() async {
    return await storage.read(key: 'bookings');
  }

  // Guardar una reserva específica por su ID
  Future<void> saveBooking(String bookingId, String bookingJson) async {
    await storage.write(key: 'booking_$bookingId', value: bookingJson);
  }

  // Obtener una reserva específica por su ID
  Future<String?> getBooking(String bookingId) async {
    return await storage.read(key: 'booking_$bookingId');
  }

  // Guardar reservas de un cliente específico
  Future<void> saveClientBookings(String clientId, String bookingsJson) async {
    await storage.write(key: 'client_bookings_$clientId', value: bookingsJson);
  }

  // Obtener reservas de un cliente específico
  Future<String?> getClientBookings(String clientId) async {
    return await storage.read(key: 'client_bookings_$clientId');
  }

  // Eliminar una reserva específica
  Future<void> deleteBooking(String bookingId) async {
    await storage.delete(key: 'booking_$bookingId');
  }

  // Limpiar todos los datos de reservas
  Future<void> clearBookingData() async {
    final allKeys = await storage.readAll();
    for (var entry in allKeys.entries) {
      if (entry.key.startsWith('booking_') ||
          entry.key.startsWith('client_bookings_') ||
          entry.key == 'bookings') {
        await storage.delete(key: entry.key);
      }
    }
  }
}