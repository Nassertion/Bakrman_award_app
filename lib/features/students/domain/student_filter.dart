class StudentFilter {
  final int? classLevel;
  final String? gender;
  final int? governorate;
  final String? schoolName;
  final String? search;
  final double? gradeMoreThan;
  final double? gradeLessThan;
  final String? sortBy; // 'grade', etc.
  final String? sortOrder; // 'asc', 'desc'

  const StudentFilter({
    this.classLevel,
    this.gender,
    this.governorate,
    this.schoolName,
    this.search,
    this.gradeMoreThan,
    this.gradeLessThan,
    this.sortBy,
    this.sortOrder,
  });

  bool get hasActiveFilters =>
      classLevel != null ||
      gender != null ||
      governorate != null ||
      (schoolName != null && schoolName!.isNotEmpty) ||
      (search != null && search!.isNotEmpty) ||
      gradeMoreThan != null ||
      gradeLessThan != null;

  StudentFilter copyWith({
    int? classLevel,
    String? gender,
    int? governorate,
    String? schoolName,
    String? search,
    double? gradeMoreThan,
    double? gradeLessThan,
    String? sortBy,
    String? sortOrder,
    bool clearClass = false,
    bool clearGender = false,
    bool clearGovernorate = false,
  }) {
    return StudentFilter(
      classLevel: clearClass ? null : (classLevel ?? this.classLevel),
      gender: clearGender ? null : (gender ?? this.gender),
      governorate: clearGovernorate ? null : (governorate ?? this.governorate),
      schoolName: schoolName ?? this.schoolName,
      search: search ?? this.search,
      gradeMoreThan: gradeMoreThan ?? this.gradeMoreThan,
      gradeLessThan: gradeLessThan ?? this.gradeLessThan,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Query params for GET /api/admin/students
  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{};
    if (classLevel != null) params['class'] = classLevel;
    if (gender != null && gender!.isNotEmpty) params['gender'] = gender;
    if (governorate != null) params['governorate'] = governorate;
    if (schoolName != null && schoolName!.isNotEmpty) params['school_name'] = schoolName;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (gradeMoreThan != null) params['gradeMoreThan'] = gradeMoreThan;
    if (gradeLessThan != null) params['gradeLessThan'] = gradeLessThan;
    if (sortBy != null && sortBy!.isNotEmpty) params['sort_by'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sort_order'] = sortOrder;
    return params;
  }

  /// Query params for GET /api/admin/students/export/csv
  Map<String, dynamic> toCsvParams() {
    final params = <String, dynamic>{};
    if (classLevel != null) params['class'] = classLevel;
    if (gender != null && gender!.isNotEmpty) params['gender'] = gender;
    if (governorate != null) params['governorate'] = governorate;
    if (schoolName != null && schoolName!.isNotEmpty) params['school_name'] = schoolName;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (gradeMoreThan != null) params['gradeMoreThen'] = gradeMoreThan; // Backend doc spelling
    if (gradeLessThan != null) params['gradeLessThen'] = gradeLessThan; // Backend doc spelling
    if (sortBy != null && sortBy!.isNotEmpty) params['sort_by'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sort_order'] = sortOrder;
    return params;
  }
}
