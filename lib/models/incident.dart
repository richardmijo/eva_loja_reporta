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
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'zone': zone,
    };
  }
}
