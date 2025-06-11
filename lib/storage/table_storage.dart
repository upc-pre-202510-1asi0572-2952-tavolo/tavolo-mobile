
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TableStorage {
  final FlutterSecureStorage storage;
  TableStorage({required this.storage});

  // Guardar todas las mesas
  Future<void> saveTables(String tablesJson) async {
    await storage.write(key: 'tables', value: tablesJson);
  }

  // Obtener todas las mesas
  Future<String?> getTables() async {
    return await storage.read(key: 'tables');
  }

  // Guardar una mesa
  Future<void> saveTable(String tableId, String tableJson) async {
    await storage.write(key: 'table_$tableId', value: tableJson);
  }

  // Obtener una mesa por su ID
  Future<String?> getTable(String tableId) async {
    return await storage.read(key: 'table_$tableId');
  }

}