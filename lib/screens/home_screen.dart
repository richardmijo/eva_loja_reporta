import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  // Repository handles all network logic — not this widget
  final _repository = IncidentRepository();
 
  List<Incident> _incidents = [];
  bool _loading = false;
  String _error = '';
  String _filter = 'todos';
 
  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }
 
  Future<void> _loadIncidents() async {
    setState(() {
      _loading = true;
      _error = '';
    });
 
    try {
      final incidents = await _repository.fetchIncidents();
      setState(() {
        _incidents = incidents;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load incidents. Check your connection.';
        _loading = false;
      });
    }
  }
 
  List<Incident> get _filteredIncidents {
    if (_filter == 'todos') return _incidents;
    return _incidents.where((i) => i.type == _filter).toList();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LojaReport'),
      ),
      drawer: _buildDrawer(context),
      body: Column(children: [_buildFilterBar(), _buildContent()]),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadIncidents,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
 
  // ── Drawer ────────────────────────────────────────────────────────────────
 
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User profile header
          UserAccountsDrawerHeader(
            accountName: const Text(
              'James Romero',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('james.romero@uide.edu.ec'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blue.shade800,
              child: const Text(
                'JR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue.shade700),
          ),
 
          // Navigation section
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop(); // close drawer
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pop(); // close drawer
              context.go('/about');
            },
          ),
        ],
      ),
    );
  }
 
  // ── Filter bar ────────────────────────────────────────────────────────────
 
  Widget _buildFilterBar() {
    return Container(
      height: 50,
      color: Colors.blue.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('todos', 'All'),
          _buildFilterChip('pothole', 'Potholes'),
          _buildFilterChip('lighting', 'Lighting'),
          _buildFilterChip('flooding', 'Flooding'),
        ],
      ),
    );
  }
 
  Widget _buildFilterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
 
  // ── Content ───────────────────────────────────────────────────────────────
 
  Widget _buildContent() {
    if (_loading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }
 
    if (_error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadIncidents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
 
    if (_filteredIncidents.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No incidents found for this filter.')),
      );
    }
 
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredIncidents.length,
        itemBuilder: (context, index) =>
            _buildIncidentCard(_filteredIncidents[index]),
      ),
    );
  }
 
  Widget _buildIncidentCard(Incident incident) {
    final color = incident.isResolved ? Colors.green : Colors.orange;
    final icon = incident.type == 'pothole'
        ? Icons.warning_amber_rounded
        : incident.type == 'lighting'
            ? Icons.lightbulb_outline
            : Icons.water_damage_outlined;
 
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zone: ${incident.zone}',
                style: const TextStyle(fontSize: 12)),
            Text(
              incident.status.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        // GoRouter navigation — passes typed Incident via extra
        onTap: () => context.push('/detail', extra: incident),
      ),
    );
  }
}
 