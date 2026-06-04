import 'package:flutter/material.dart';
import '../controllers/incident_controller.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = IncidentController();
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final currentFilter = controller.filtro;
        return Container(
          height: 60,
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildChipFiltro(context, controller, currentFilter, 'todos', 'All'),
              _buildChipFiltro(context, controller, currentFilter, 'pothole', 'Potholes'),
              _buildChipFiltro(context, controller, currentFilter, 'lighting', 'Lighting'),
              _buildChipFiltro(context, controller, currentFilter, 'flooding', 'Flooding'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChipFiltro(
    BuildContext context,
    IncidentController controller,
    String currentFilter,
    String valor,
    String etiqueta,
  ) {
    final theme = Theme.of(context);
    final seleccionado = currentFilter == valor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: GestureDetector(
        onTap: () => controller.setFiltro(valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: seleccionado ? theme.colorScheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (!seleccionado)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
            ],
            border: Border.all(
              color: seleccionado ? theme.colorScheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              etiqueta,
              style: TextStyle(
                color: seleccionado ? Colors.white : theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
