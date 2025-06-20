import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/data/models/bookings/booking_request.dart';
import 'package:tavolo_mobile/data/repositories/booking_repository.dart';
import 'package:tavolo_mobile/storage/booking_storage.dart';
import 'package:tavolo_mobile/storage/secure_storage.dart';

class ReservationModal extends StatefulWidget {
  final int tableId;
  final String tableName;
  final int capacity;
  final String zone;

  const ReservationModal({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.capacity,
    required this.zone,
  }) : super(key: key);

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  int? _selectedSlotId;
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  List<dynamic> _availableSlots = [];
  String? _errorMessage;
  late final BookingRepository _repository;

  @override
  void initState() {
    super.initState();

    // Inicializar datos de localización
    initializeDateFormatting('es_ES', null).then((_) {
      _repository = BookingRepository(
          apiClient: ApiClient(
            httpClient: http.Client(),
            secureStorage: SecureStorage(storage: FlutterSecureStorage()),
            baseUrl: 'http://10.0.2.2:8080',
          ),
          bookingStorage: BookingStorage(storage: FlutterSecureStorage())
      );

      _loadAvailableSlots();
    });
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _errorMessage = null;
      _selectedSlot = null;
      _selectedSlotId = null;
    });

    try {
      // Formato de fecha YYYY-MM-DD
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Llamar al método correcto del repositorio
      final slots = await _repository.getTableScheduleByIdAndDate(
          widget.tableId.toString(), formattedDate);

      setState(() {
        _availableSlots = slots is List ? slots : [];
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los horarios: $e';
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8B5A3C)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableSlots();
    }
  }

  Future<void> _confirmReservation() async {
    if (_selectedSlotId == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona un horario';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clientId = 1; // En producción, obtener del servicio de autenticación

      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final bookingRequest = BookingRequest(
        clientId: clientId,
        tableId: widget.tableId,
        bookingDate: formattedDate,
        slotIds: [_selectedSlotId!],
      );

      await _repository.createBooking(bookingRequest);

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada correctamente'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al confirmar la reserva: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y botón de cierre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reservar mesa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información de la mesa
              const Text(
                'Información de la mesa:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Mesa:', widget.tableName),
              _buildInfoRow('Capacidad:', '${widget.capacity} personas'),
              _buildInfoRow('Zona:', widget.zone),
              const SizedBox(height: 16),

              // Selector de fecha
              const Text(
                'Selecciona una fecha:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE d, MMMM yyyy', 'es_ES').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF8B5A3C),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Selector de horario
              const Text(
                'Selecciona un horario:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildSlotsSection(),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Botón de confirmación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A3C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Confirmar reserva',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsSection() {
    if (_isLoadingSlots) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5A3C)),
            ),
          )
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No hay horarios disponibles para esta fecha',
          style: TextStyle(color: Color(0xFF666666)),
        ),
      );
    }

    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _availableSlots.length,
        itemBuilder: (context, index) {
          final slot = _availableSlots[index];
          final slotText = "${slot['startTime']} - ${slot['endTime']}";
          final slotId = slot['id'];
          final isAvailable = slot['status'] == 'AVAILABLE';

          return RadioListTile<String>(
            title: Text(
              slotText,
              style: TextStyle(
                color: isAvailable ? Colors.black : Colors.grey,
              ),
            ),
            value: slotText,
            groupValue: _selectedSlot,
            activeColor: const Color(0xFF8B5A3C),
            onChanged: isAvailable ? (value) {
              setState(() {
                _selectedSlot = value;
                _selectedSlotId = slotId;
              });
            } : null,
          );
        },
      ),
    );
  }
}