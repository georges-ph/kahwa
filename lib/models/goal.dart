class Goal {
  String? id;
  String? title;
  String? description;
  int? current;
  int? target;

  Goal({
    this.id,
    this.title,
    this.description,
    this.current,
    this.target,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'current': current,
      'target': target,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      current: map['current']?.toInt(),
      target: map['target']?.toInt(),
    );
  }
}
