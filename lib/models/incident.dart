class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.type,
    required this.zone,
    required this.status,
    required this.description,
  });

  final String id;
  final String title;
  final String type;
  final String zone;
  final String status;
  final String description;

  bool get isResolved => status == 'resolved';

  /// 🔴 pending, ✅ resolved (share text and UI alerts).
  String get statusEmoji => isResolved ? '✅' : '🔴';

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      status: json['status'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'zone': zone,
        'status': status,
        'description': description,
      };
}
