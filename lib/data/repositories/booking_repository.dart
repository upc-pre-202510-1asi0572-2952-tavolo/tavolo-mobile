import 'dart:convert';
import 'package:tavolo_mobile/storage/booking_storage.dart';
import 'package:tavolo_mobile/data/models/bookings/booking_request.dart';
import 'package:tavolo_mobile/data/models/bookings/booking_response.dart';
import '../../conf/api_client.dart';

class BookingRepository {
  final ApiClient apiClient;
  final BookingStorage bookingStorage;

  BookingRepository({
    required this.apiClient,
    required this.bookingStorage,
  });

  // Crear una nueva reserva
  Future<dynamic> createBooking(BookingRequest bookingRequest) async {
    try {
      final response = await apiClient.post(
        '/api/v1/bookings',
        body: bookingRequest.toJson(),
      );

      // Guardar la reserva en el almacenamiento local
      if (response != null && response['id'] != null) {
        await bookingStorage.saveBooking(
          response['id'].toString(),
          json.encode(response),
        );
      }

      return response;
    } catch (e) {
      throw Exception('Error al crear la reserva: $e');
    }
  }

  // Obtener todas las reservas
  Future<List<dynamic>> getAllBookings() async {
    try {
      final List<dynamic> bookings = await apiClient.get('/api/v1/bookings');
      await bookingStorage.saveAllBookings(json.encode(bookings));
      return bookings;
    } catch (e) {
      throw Exception('Error al obtener las reservas: $e');
    }
  }

  // Obtener una reserva específica por su ID
  Future<dynamic> getBookingById(String bookingId) async {
    try {
      final booking = await apiClient.get('/api/v1/bookings/$bookingId');
      await bookingStorage.saveBooking(bookingId, json.encode(booking));
      return booking;
    } catch (e) {
      throw Exception('Error al obtener la reserva: $e');
    }
  }

  // Obtener reservas de un cliente específico
  Future<List<dynamic>> getBookingsByClientId(String clientId) async {
    try {
      final List<dynamic> bookings = await apiClient.get('/api/v1/bookings/client/$clientId');
      await bookingStorage.saveClientBookings(clientId, json.encode(bookings));
      return bookings;
    } catch (e) {
      throw Exception('Error al obtener las reservas del cliente: $e');
    }
  }

  // Eliminar una reserva específica
  Future<void> deleteBooking(String bookingId) async {
    try {
      await apiClient.delete('/api/v1/bookings/$bookingId');
      await bookingStorage.deleteBooking(bookingId);
    } catch (e) {
      throw Exception('Error al eliminar la reserva: $e');
    }
  }

  // Obtener horarios disponibles para una mesa en una fecha
  Future<List<dynamic>> getAvailableTimeSlots(int tableId, String date) async {
    try {
      final List<dynamic> slots = await apiClient.get(
          '/api/v1/tables/$tableId/availability?date=$date'
      );
      return slots;
    } catch (e) {
      throw Exception('Error al obtener los horarios disponibles: $e');
    }
  }

  // En BookingRepository
  Future<List<dynamic>> getTableScheduleByIdAndDate(String tableId, String date) async {
    try {
      // Usar el endpoint correcto
      final response = await apiClient.get('/api/v1/tables/$tableId/schedule?date=$date');
      return response is List ? response : [];
    } catch (e) {
      throw Exception('Error al obtener los horarios disponibles: $e');
    }
  }
}