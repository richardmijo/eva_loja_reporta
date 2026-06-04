class Incident {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final String zone;

  const Incident({
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

  /// Returns `true` when the incident status is "pending" (API value).
  bool get isPending => status == 'pending';

  /// Generates the shareable text in the exact required format.
  String get shareText =>
      'Incident in $zone: $title\n'
      'Status: ${status[0].toUpperCase()}${status.substring(1)}\n'
      'Reported on LojaReport - Loja, Ecuador';
}
