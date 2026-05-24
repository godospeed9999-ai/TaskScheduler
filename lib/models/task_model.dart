class TaskModel {
  final int? id;
  final String title;
  final String startTime;
  final String endTime;
  final String category;
  final String? description;
  final bool isCompleted;
  final String date; // ISO date string YYYY-MM-DD

  const TaskModel({
    this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.description,
    this.isCompleted = false,
    required this.date,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? startTime,
    String? endTime,
    String? category,
    String? description,
    bool? isCompleted,
    String? date,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date,
    };
  }
}
