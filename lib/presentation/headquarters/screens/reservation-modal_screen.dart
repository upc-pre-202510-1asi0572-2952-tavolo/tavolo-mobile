import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tavolo_mobile/data/models/bookings/create_booking_request.dart';
import '../../../data/models/tables/availability_slot.dart';
import '../../../data/models/bookings/create_booking_request.dart';
import 'package:http/http.dart' as http;

class ReservationModal extends StatefulWidget {
  final int tableId;
  final String tableName;
  final int capacity;
  final String zone;

  const ReservationModal({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.capacity,
    required this.zone,
  });

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  List<String> availableHours = [];
  List<String> reservedHours = [];
  String? selectedHour;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableHours();
  }

  Future<void> fetchAvailableHours() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final url = Uri.parse('http://10.0.2.2:8080/api/v1/tables/${widget.tableId}/schedule?date=$today');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final slots = data.map((e) => AvailabilitySlot.fromJson(e)).toList();

        setState(() {
          availableHours = slots.where((s) => s.available).map((s) => s.hour).toList();
          reservedHours = slots.where((s) => !s.available).map((s) => s.hour).toList();
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al cargar horarios: $e");
    }
  }

  void reservar() async {
    if (selectedHour == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final booking = CreateBookingRequest(
        tableId: widget.tableId,
        date: today,
        hour: selectedHour!,
    );

    final url = Uri.parse('http://10.0.2.2:8080/api/v1/bookings');
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Se reservó correctamente"),
            content: const Text("Revisa tus reservas en la sección Inicio"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Aceptar"),
              ),
            ],
          ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al reservar: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.tableName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Capacidad: ${widget.capacity} personas"),
            Text("Zona: ${widget.zone}"),
            const SizedBox(height: 10),
            const Text("Hora:"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...availableHours.map((hour) => ChoiceChip(
                  label: Text(hour),
                  selected: selectedHour == hour,
                  onSelected: (_) {
                    setState(() => selectedHour = hour);
                    },
                )),
                ...reservedHours.map((hour) => Chip(
                  label: Text(hour),
                  backgroundColor: Colors.red[100],
                )),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: selectedHour != null ? reservar : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                child: const Text("Reservar"),
            ),
          ],
        ),
      ),
    );
  }
}
