class Incidente {
  final String id;
  final String title;
  final String zone;
  final String type;
  final String status;
  final String description;

  const Incidente({
    required this.id,
    required this.title,
    required this.zone,
    required this.type,
    required this.status,
    required this.description,
  });

  factory Incidente.fromJson(Map<String, dynamic> json) {
    return Incidente(
      id:          json['id']?.toString()          ?? '',
      title:       json['title']?.toString()       ?? '',
      zone:        json['zone']?.toString()         ?? '',
      type:        json['type']?.toString()         ?? '',
      status:      json['status']?.toString()       ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  bool get esResuelto => status == 'resolved';
}
