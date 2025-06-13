
import 'package:tavolo_mobile/storage/table_storage.dart';

import '../../conf/api_client.dart';

class TableRepository {
  final ApiClient apiClient;

  final TableStorage tableStorage;

  TableRepository({
    required this.apiClient,
    required this.tableStorage,
  });

  // Métodos para manejar las mesas

  //Obtiene una lista de mesas por su sede. /api/v1/tables/headquarter/{headquarterId}
  Future<List<dynamic>> getTablesByHeadquarterId(String headquarterId) async {
    try {
      // Corrige la ruta - asegúrate que coincida con el endpoint real
      final response = await apiClient.get('/api/v1/tables/headquarter/$headquarterId');

      // Si la respuesta está vacía, devolver una lista vacía
      if (response == null) return [];

      return response is List ? response : [];
    } catch (e) {
      // Mejorar el mensaje de error para depuración
      print('Error detallado: $e');
      throw Exception('Error al obtener las mesas por sede: $e');
    }
  }

  //Obtiene los horarios de una mesa por su ID. /api/v1/tables/{tableId}/schedule
  Future<dynamic> getTableScheduleByTableId(String tableId) async {
    try {
      final response = await apiClient.get('/api/v1/tables/$tableId/schedule');
      final schedule = response; // Asumiendo que la respuesta ya está decodificada

      // Guardar el horario de la mesa específica en el almacenamiento
      await tableStorage.saveTable(tableId, schedule.toString());

      return schedule;
    } catch (e) {
      throw Exception('Error al obtener el horario de la mesa: $e');
    }
  }

  // Obtiene la lista de todas las mesas.
  Future<List<dynamic>> getTables() async {
    try {
      // La respuesta ya viene decodificada del apiClient
      final List<dynamic> tables = await apiClient.get('/api/v1/tables');

      // Guardar la lista de mesas en el almacenamiento
      await tableStorage.saveTables(tables.toString());

      return tables;
    } catch (e) {
      throw Exception('Error al obtener las mesas: $e');
    }
  }

  // Obtiene una mesa específica por su ID.
  Future<dynamic> getTableByTableId(String tableId) async {
    try {
      final response = await apiClient.get('/api/v1/tables/$tableId');
      final table = response; // Asumiendo que la respuesta ya está decodificada

      // Guardar la mesa específica en el almacenamiento
      await tableStorage.saveTable(tableId, table.toString());

      return table;
    } catch (e) {
      throw Exception('Error al obtener la mesa: $e');
    }
  }

}
