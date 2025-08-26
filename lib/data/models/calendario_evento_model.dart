class CalendarioEvento {
  // La fecha del evento en formato 'YYYY-MM-DD'

  CalendarioEvento({
    required this.id,
    required this.title,
    required this.start,
  });

  factory CalendarioEvento.fromJson(Map<String, dynamic> json) =>
      CalendarioEvento(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        title: json['title']?.toString() ?? '',
        start: json['start']?.toString() ?? '',
      );
  final int id;
  final String title;
  final String start;
}
