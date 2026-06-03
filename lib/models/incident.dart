class Incident {
  final String id;
  final String title;
  final String type;
  final String zone;
  final String status;
  final String description;

  const Incident({
    required this.id,
    required this.title,
    required this.type,
    required this.zone,
    required this.status,
    required this.description,
  });

  bool get isResolved => status == 'resolved';

  String get displayType {
    switch (type) {
      case 'pothole':
        return 'Pothole';
      case 'lighting':
        return 'Lighting';
      case 'flooding':
        return 'Flooding';
      default:
        return type;
    }
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      zone: json['zone'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
