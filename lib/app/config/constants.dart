class AppConstants {
  AppConstants._();

  static const String appName = 'جائزة ال باكرمان';
  static const String appSubTitle =
      'منظومة إدارة وتسجيل بيانات الطلاب والتفوق العلمي';

  /// Governorates lookup table (1 to 12)
  static const Map<int, String> governorates = {
    1: 'الرياض',
    2: 'مكة المكرمة',
    3: 'المدينة المنورة',
    4: 'القصيم',
    5: 'المنطقة الشرقية',
    6: 'عسير',
    7: 'تبوك',
    8: 'حائل',
    9: 'الحدود الشمالية',
    10: 'جازان',
    11: 'نجران',
    12: 'الجوف',
  };

  /// Classes lookup table (1 to 12)
  static const Map<int, String> classes = {
    1: 'الصف الأول الابتدائي',
    2: 'الصف الثاني الابتدائي',
    3: 'الصف الثالث الابتدائي',
    4: 'الصف الرابع الابتدائي',
    5: 'الصف الخامس الابتدائي',
    6: 'الصف السادس الابتدائي',
    7: 'الصف الأول المتوسط',
    8: 'الصف الثاني المتوسط',
    9: 'الصف الثالث المتوسط',
    10: 'الصف الأول الثانوي',
    11: 'الصف الثاني الثانوي',
    12: 'الصف الثالث الثانوي',
  };

  /// Genders
  static const Map<String, String> genders = {'male': 'ذكر', 'female': 'أنثى'};

  static String getGovernorateName(dynamic id) {
    if (id == null) return 'غير محدد';
    final intId = id is int ? id : int.tryParse(id.toString());
    return governorates[intId] ?? 'محافظة $id';
  }

  static String getClassName(dynamic id) {
    if (id == null) return 'غير محدد';
    final intId = id is int ? id : int.tryParse(id.toString());
    return classes[intId] ?? 'الصف $id';
  }

  static String getGenderName(String? gender) {
    if (gender == null) return 'غير محدد';
    return genders[gender.toLowerCase()] ?? gender;
  }
}
