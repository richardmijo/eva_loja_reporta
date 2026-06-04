class Incident {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final String zone;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.zone,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}
