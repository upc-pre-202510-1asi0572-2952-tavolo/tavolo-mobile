import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MenuStorage {
  final FlutterSecureStorage storage;
  MenuStorage({required this.storage});

  // Guardar todos los elementos del menú
  Future<void> saveAllMenuItems(String menuItemsJson) async {
    await storage.write(key: 'menu_items', value: menuItemsJson);
  }

  // Obtener todos los elementos del menú
  Future<String?> getAllMenuItems() async {
    return await storage.read(key: 'menu_items');
  }

  // Guardar un elemento específico del menú por su ID
  Future<void> saveMenuItem(String itemId, String menuItemJson) async {
    await storage.write(key: 'menu_item_$itemId', value: menuItemJson);
  }

  // Obtener un elemento específico del menú por su ID
  Future<String?> getMenuItem(String itemId) async {
    return await storage.read(key: 'menu_item_$itemId');
  }

  // Guardar elementos de una categoría específica
  Future<void> saveMenuItemsByCategory(String category, String categoryItemsJson) async {
    await storage.write(key: 'menu_category_$category', value: categoryItemsJson);
  }

  // Obtener elementos de una categoría específica
  Future<String?> getMenuItemsByCategory(String category) async {
    return await storage.read(key: 'menu_category_$category');
  }

  // Limpiar todos los datos del menú
  Future<void> clearMenuData() async {
    final allKeys = await storage.readAll();
    for (var entry in allKeys.entries) {
      if (entry.key.startsWith('menu_')) {
        await storage.delete(key: entry.key);
      }
    }
  }

}