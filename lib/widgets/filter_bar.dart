import 'package:flutter/material.dart';
import '../controllers/incident_controller.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = IncidentController();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final currentFilter = controller.filtro;
        return Container(
          height: 50,
          color: Colors.blue.shade50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChipFiltro(controller, currentFilter, 'todos', 'All'),
              _buildChipFiltro(controller, currentFilter, 'pothole', 'Potholes'),
              _buildChipFiltro(controller, currentFilter, 'lighting', 'Lighting'),
              _buildChipFiltro(controller, currentFilter, 'flooding', 'Flooding'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChipFiltro(
    IncidentController controller,
    String currentFilter,
    String valor,
    String etiqueta,
  ) {
    final seleccionado = currentFilter == valor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () => controller.setFiltro(valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: seleccionado ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            etiqueta,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
