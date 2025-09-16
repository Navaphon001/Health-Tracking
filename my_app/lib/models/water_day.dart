class WaterDay {
  final String date; // yyyy-MM-dd
  int count;         // ดื่มกี่แก้ว/ครั้งในวันนั้น
  int goal;          // เป้าหมายต่อวัน (default 8)

  WaterDay({required this.date, required this.count, this.goal = 8});

  factory WaterDay.fromJson(Map<String, dynamic> json) => WaterDay(
        date: json['date'] as String,
        count: (json['count'] ?? 0) as int,
        goal: (json['goal'] ?? 8) as int,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        'goal': goal,
      };

  static String keyFromDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
