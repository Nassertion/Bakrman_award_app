class Student {
  final int id;
  final String firstName;
  final String? secondName;
  final String? thirdName;
  final String lastName;
  final String gender;
  final dynamic governorate;
  final dynamic classLevel;
  final String schoolName;
  final double grade;
  final String? imageUrl;
  final String? phone1;
  final String? phone2;
  final String? address;

  Student({
    required this.id,
    required this.firstName,
    this.secondName,
    this.thirdName,
    required this.lastName,
    required this.gender,
    this.governorate,
    this.classLevel,
    required this.schoolName,
    required this.grade,
    this.imageUrl,
    this.phone1,
    this.phone2,
    this.address,
  });

  String get fullName {
    final parts = [firstName, secondName, thirdName, lastName]
        .where((e) => e != null && e.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'طالب #$id';
    return parts.join(' ');
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    double parsedGrade = 0.0;
    if (json['grade'] != null) {
      parsedGrade = double.tryParse(json['grade'].toString()) ?? 0.0;
    }

    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0;
    }

    return Student(
      id: parsedId,
      firstName: json['first_name']?.toString() ?? '',
      secondName: json['second_name']?.toString(),
      thirdName: json['third_name']?.toString(),
      lastName: json['last_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
      governorate: json['governorate'],
      classLevel: json['class'],
      schoolName: json['school_name']?.toString() ?? '',
      grade: parsedGrade,
      imageUrl: json['image_url']?.toString() ?? json['cert_image']?.toString(),
      phone1: json['phone1']?.toString(),
      phone2: json['phone2']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'second_name': secondName,
        'third_name': thirdName,
        'last_name': lastName,
        'gender': gender,
        'governorate': governorate,
        'class': classLevel,
        'school_name': schoolName,
        'grade': grade,
        'image_url': imageUrl,
        'phone1': phone1,
        'phone2': phone2,
        'address': address,
      };
}
