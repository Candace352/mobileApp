class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String? location;
  final String? salary;
  final dynamic createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    this.location,
    this.salary,
    this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      description: map['description'] ?? '',
      location: map['location'],
      salary: map['salary'],
      createdAt: map['createdAt'],
    );
  }

  factory Job.fromJson(Map<String, dynamic> map) {
    return Job.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'description': description,
      'location': location,
      'salary': salary,
      'createdAt': createdAt,
    };
  }
}
