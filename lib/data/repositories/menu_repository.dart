import 'dart:convert';
import '../../conf/api_client.dart';
import '../../storage/menu_storage.dart';

class MenuRepository {
  final ApiClient apiClient;
  final MenuStorage menuStorage;

  MenuRepository({
    required this.apiClient,
    required this.menuStorage,
  });

  // Obtiene todos los elementos del menú
  Future<List<dynamic>> getMenuItems() async {
    try {
      final List<dynamic> menuItems = await apiClient.get('/api/v1/menu');

      // Guardar la lista de menú en el almacenamiento
      await menuStorage.saveAllMenuItems(json.encode(menuItems));

      return menuItems;
    } catch (e) {
      throw Exception('Error al obtener los elementos del menú: $e');
    }
  }

  // Obtiene un elemento específico del menú por su ID
  Future<dynamic> getMenuItemById(String itemId) async {
    try {
      final menuItem = await apiClient.get('/api/v1/menu/$itemId');

      // Guardar el elemento específico en el almacenamiento
      await menuStorage.saveMenuItem(itemId, json.encode(menuItem));

      return menuItem;
    } catch (e) {
      throw Exception('Error al obtener el elemento del menú: $e');
    }
  }

  // Obtiene elementos del menú por categoría
  Future<List<dynamic>> getMenuItemsByCategory(String category) async {
    try {
      final List<dynamic> categoryItems = await apiClient.get('/api/v1/menu/category/$category');

      // Guardar los elementos de la categoría en el almacenamiento
      await menuStorage.saveMenuItemsByCategory(category, json.encode(categoryItems));

      return categoryItems;
    } catch (e) {
      throw Exception('Error al obtener elementos del menú por categoría: $e');
    }
  }
}