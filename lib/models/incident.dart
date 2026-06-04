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

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString() ?? '',
    );
  }

  bool get isResolved => status == 'resolved';

  String get typeLabel {
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

  String get clipboardMessage =>
      'Incident in $zone: $title Stotus: $status) '
      'Reported on LojaReport - Loja, Ecuadar';
}
