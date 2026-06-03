class Incident {
  final String id;
  final String title;
  final String description;
  final String type;
  final String zone;
  final String status;
  final bool isFavorite;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.zone,
    required this.status,
    this.isFavorite = false,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Incidente sin título',
      description: json['description']?.toString() ?? 'Sin descripción',
      type: json['type']?.toString() ?? 'other',
      zone: json['zone']?.toString() ?? 'Zona no especificada',
      status: json['status']?.toString() ?? 'pending',
      isFavorite: false,
    );
  }

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? zone,
    String? status,
    bool? isFavorite,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
