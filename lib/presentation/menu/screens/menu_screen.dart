import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tavolo_mobile/data/models/menu/menu_response.dart';
import 'package:tavolo_mobile/data/repositories/menu_repository.dart';
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/storage/secure_storage.dart';
import 'package:tavolo_mobile/storage/menu_storage.dart';

class MenuScreen extends StatefulWidget {
  final MenuRepository? repository;

  const MenuScreen({super.key, this.repository});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final MenuRepository _repository;
  bool _isLoading = true;
  String? _errorMessage;
  List<MenuResponse> _menuItems = [];
  Map<String, List<MenuResponse>> _categorizedMenu = {};

  // Colores consistentes con el resto de la app
  static const Color primaryColor = Color(0xFF8B5A3C);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color cardColor = Colors.white;
  static const double cardBorderRadius = 12.0;

  @override
  void initState() {
    super.initState();

    // Inicializar el repositorio si no se proporciona uno
    _repository = widget.repository ?? MenuRepository(
        apiClient: ApiClient(
          httpClient: http.Client(),
          secureStorage: SecureStorage(storage: FlutterSecureStorage()),
          baseUrl: 'http://10.0.2.2:8080',
        ),
        menuStorage: MenuStorage(storage: FlutterSecureStorage())
    );

    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.getMenuItems();
      final items = data.map((item) => MenuResponse.fromJson(item)).toList();

      // Agrupar por categoría
      final Map<String, List<MenuResponse>> categorized = {};
      for (var item in items) {
        if (!categorized.containsKey(item.category)) {
          categorized[item.category] = [];
        }
        categorized[item.category]!.add(item);
      }

      setState(() {
        _menuItems = items;
        _categorizedMenu = categorized;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menú',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ))
          : _errorMessage != null
          ? _buildErrorView()
          : _buildMenuList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $_errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMenuItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    if (_categorizedMenu.isEmpty) {
      return const Center(
        child: Text('No hay productos disponibles en el menú'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _categorizedMenu.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return _buildCategorySection(category, items);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<MenuResponse> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildMenuItemCard(item);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            _buildItemImage(item.imageBase64),
            const SizedBox(width: 12),
            // Detalles del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/. ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String imageBase64) {
    if (imageBase64.isEmpty) {
      return _buildPlaceholderImage();
    }

    try {
      final imageBytes = base64Decode(imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageBytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      );
    } catch (e) {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: primaryColor,
        size: 32,
      ),
    );
  }
}