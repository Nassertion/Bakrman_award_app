class Validators {
  Validators._();

  static String? requiredField(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  static String? validateGrade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الدرجة / المعدل';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'يرجى إدخال قيمة رقمية صحيحة';
    }
    if (number < 0 || number > 100) {
      return 'الدرجة يجب أن تكون بين 0 و 100';
    }
    return null;
  }

  static String? validateDropdownInt(int? value, [String fieldName = 'القيمة']) {
    if (value == null || value <= 0) {
      return 'يرجى اختيار $fieldName';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional per API spec
    }
    final trimmed = value.trim();
    final phoneRegExp = RegExp(r'^[0-9\+\-\s]{8,15}$');
    if (!phoneRegExp.hasMatch(trimmed)) {
      return 'صيغة رقم الجوال غير صحيحة';
    }
    return null;
  }
}
