class TodoModel {
  final String email;
  final String title;
  final String deadLine;
  final String desc;
  final int id;
  // Add a new property for the completion status
  final bool isCompleted;

  TodoModel({
    required this.title,
    required this.id,
    required this.email,
    required this.desc,
    required this.deadLine,
    this.isCompleted = false, // Set a default value for the new property
  });

  // Factory constructor to create a TodoModel from a JSON map
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      email: json["email"],
      deadLine: json["createdAt"],
      desc: json["desc"],
      isCompleted: json['isCompleted'] ?? false, // Handle cases where isCompleted might be missing
    );
  }

  // Method to convert a TodoModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      "email": email,
      "createdAt": deadLine,
      "desc": desc,
      'isCompleted': isCompleted,
    };
  }

  // The copyWith method to create a new TodoModel with updated values
  TodoModel copyWith({
    String? email,
    String? title,
    String? deadLine,
    String? desc,
    int? id,
    bool? isCompleted,
  }) {
    return TodoModel(
      email: email ?? this.email,
      title: title ?? this.title,
      deadLine: deadLine ?? this.deadLine,
      desc: desc ?? this.desc,
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}