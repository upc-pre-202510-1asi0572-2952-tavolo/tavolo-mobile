import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';
import 'package:tavolo_mobile/data/repositories/auth_repository.dart';
import 'package:tavolo_mobile/data/repositories/booking_repository.dart';
import 'package:tavolo_mobile/data/repositories/headquarter_repository.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_bloc.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_event.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_state.dart';
import 'package:tavolo_mobile/storage/booking_storage.dart';
import 'package:tavolo_mobile/storage/headquarter_storage.dart';
import 'package:tavolo_mobile/storage/secure_storage.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar repositorios
    final secureStorage = SecureStorage(storage: const FlutterSecureStorage());
    final apiClient = ApiClient(
      httpClient: http.Client(),
      secureStorage: secureStorage,
      baseUrl: 'http://10.0.2.2:8080',
    );

    final authRepository = AuthRepository(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    final bookingRepository = BookingRepository(
      apiClient: apiClient,
      bookingStorage: BookingStorage(storage: const FlutterSecureStorage()),
    );

    final headquarterRepository = HeadquarterRepository(
      apiClient: apiClient,
      headquarterStorage: HeadquarterStorage(storage: const FlutterSecureStorage()),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TAVOLO',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {
              // Navegación a notificaciones
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            return _HomeContent(
              user: state.user,
              authRepository: authRepository,
              bookingRepository: bookingRepository,
              headquarterRepository: headquarterRepository,
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
            ),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final dynamic user;
  final AuthRepository authRepository;
  final BookingRepository bookingRepository;
  final HeadquarterRepository headquarterRepository;

  const _HomeContent({
    required this.user,
    required this.authRepository,
    required this.bookingRepository,
    required this.headquarterRepository,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isLoadingBookings = true;
  bool _isLoadingHeadquarters = true;
  List<dynamic> _activeBookings = [];
  List<dynamic> _headquarters = [];
  String? _bookingsError;
  String? _headquartersError;

  @override
  void initState() {
    super.initState();
    _loadUserBookings();
    _loadHeadquarters();
  }

  Future<void> _loadUserBookings() async {
    try {
      setState(() {
        _isLoadingBookings = true;
        _bookingsError = null;
      });

      // Obtener el usuario actual para el clientId
      final currentUser = await widget.authRepository.getCurrentUser();
      final clientId = currentUser?.id.toString() ?? "";

      if (clientId.isEmpty) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Cargar las reservas del usuario
      final bookings = await widget.bookingRepository.getBookingsByClientId(clientId);

      setState(() {
        _activeBookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _bookingsError = e.toString();
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _loadHeadquarters() async {
    try {
      setState(() {
        _isLoadingHeadquarters = true;
        _headquartersError = null;
      });

      // Cargar todas las sedes
      final headquarters = await widget.headquarterRepository.getHeadquarters();

      setState(() {
        _headquarters = headquarters;
        _isLoadingHeadquarters = false;
      });
    } catch (e) {
      setState(() {
        _headquartersError = e.toString();
        _isLoadingHeadquarters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserBookings();
        await _loadHeadquarters();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de saludo
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inicio',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Hola, ${widget.user.username}!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Reserva Activa
            _buildActiveBookingSection(),

            // Nuestras sedes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuestras sedes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/headquarters');
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de sedes
            _buildHeadquartersGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingSection() {
    if (_isLoadingBookings) {
      return _buildLoadingBooking();
    }

    if (_bookingsError != null) {
      return _buildErrorBooking();
    }

    if (_activeBookings.isEmpty) {
      return _buildNoActiveBooking();
    }

    _activeBookings.sort((a, b) => DateTime.parse(b['bookingDate']).compareTo(DateTime.parse(a['bookingDate'])));

    // Mostrar la primera reserva activa
    final booking = _activeBookings.first;
    String headquarterName = 'Sede desconocida';
    // Buscar en la lista de sedes el nombre correspondiente al ID
    for (var headquarter in _headquarters) {
      if (headquarter['id'] == booking['headquarterId']) {
        headquarterName = headquarter['name'];
        break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.brown[100]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Reserva Activa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.brown[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mesa #${booking['tableNumber']} • $headquarterName',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatBookingDate(booking['bookingDate']),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Horario: ${booking['bookingSlots'].map((slot) => '${slot['startTime']} - ${slot['endTime']}').join(', ')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBooking() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.brown[100]!,
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
        ),
      ),
    );
  }

  Widget _buildErrorBooking() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[100]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Error al cargar reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _bookingsError ?? 'Error desconocido',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadUserBookings,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveBooking() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Sin reservas activas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No tienes reservas activas en este momento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.go('/headquarters');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Reservar ahora'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadquartersGrid() {
    if (_isLoadingHeadquarters) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
          ),
        ),
      );
    }

    if (_headquartersError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'Error al cargar sedes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _headquartersError ?? 'Error desconocido',
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadHeadquarters,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_headquarters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No hay sedes disponibles',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Muestra hasta 4 sedes en el grid
    final displayHeadquarters = _headquarters.length > 4
        ? _headquarters.sublist(0, 4)
        : _headquarters;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: displayHeadquarters.length,
      itemBuilder: (context, index) {
        final headquarter = displayHeadquarters[index];
        return _buildLocationCard(
          context,
          headquarter['name'] ?? 'Sede sin nombre',
          Icons.storefront,
              () {
            // Navegar a la pantalla de detalles de la sede
            Navigator.pushNamed(
              context,
              '/headquarters/${headquarter['id']}',
              arguments: headquarter,
            );
          },
        );
      },
    );
  }

  Widget _buildLocationCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.brown,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBookingDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'Fecha no disponible';
    }

    try {
      final dateTime = DateTime.parse(date);
      final formatter = DateFormat('EEEE d, MMMM yyyy', 'es_ES');
      return formatter.format(dateTime);
    } catch (e) {
      return date;
    }
  }
}