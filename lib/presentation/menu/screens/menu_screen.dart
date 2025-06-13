import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Carta del Día',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Categorías de menú
          _buildMenuCategory(
              title: 'Entradas',
              items: [
                _MenuItem(name: 'Ensalada César', price: '8.500', description: 'Lechuga romana, crutones, aderezo César y parmesano'),
                _MenuItem(name: 'Carpaccio de Res', price: '12.900', description: 'Finas láminas de res, alcaparras y parmesano'),
              ]
          ),

          const SizedBox(height: 24),

          _buildMenuCategory(
              title: 'Platos Principales',
              items: [
                _MenuItem(name: 'Risotto de Champiñones', price: '15.900', description: 'Arroz arborio, champiñones, vino blanco y parmesano'),
                _MenuItem(name: 'Lomo Saltado', price: '18.500', description: 'Lomo fino salteado con cebolla, tomate y papas fritas'),
              ]
          ),

          const SizedBox(height: 24),

          _buildMenuCategory(
              title: 'Postres',
              items: [
                _MenuItem(name: 'Tiramisú', price: '7.900', description: 'Clásico postre italiano con café y mascarpone'),
                _MenuItem(name: 'Flan de Caramelo', price: '6.500', description: 'Suave flan con salsa de caramelo'),
              ]
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory({required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de categoría
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.brown.shade200),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
        ),

        // Items del menú
        ...items.map((item) => _buildMenuItem(item)).toList(),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenido del ítem
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Precio
            Text(
              '${item.price} COP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.brown[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String name;
  final String price;
  final String description;

  _MenuItem({
    required this.name,
    required this.price,
    required this.description,
  });
}