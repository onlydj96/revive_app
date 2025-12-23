class FormValidators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필드'}를 입력해주세요';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength,
      [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필드'}를 입력해주세요';
    }
    if (value.trim().length < minLength) {
      return '${fieldName ?? '필드'}는 최소 $minLength글자 이상이어야 합니다';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength,
      [String? fieldName]) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? '필드'}는 최대 $maxLength글자까지 입력 가능합니다';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  static String? validatePassword(String? value, {bool strict = true}) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다';
    }
    if (strict) {
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return '비밀번호에 대문자가 최소 1자 포함되어야 합니다';
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return '비밀번호에 소문자가 최소 1자 포함되어야 합니다';
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return '비밀번호에 숫자가 최소 1자 포함되어야 합니다';
      }
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return '비밀번호에 특수문자(!@#\$%^&* 등)가 최소 1자 포함되어야 합니다';
      }
    }
    return null;
  }

  /// Validate password confirmation matches
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// Get password strength description
  static String getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return '약함';
    if (score <= 4) return '보통';
    return '강함';
  }

  static String? validatePositiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return '${fieldName ?? '숫자'}는 양수로 입력해주세요';
    }
    return null;
  }

  static String? validateUrl(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    try {
      Uri.parse(value.trim());
      return null;
    } catch (e) {
      return '올바른 ${fieldName ?? 'URL'} 형식을 입력해주세요';
    }
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '전화번호를 입력해주세요';
    }

    final phoneRegex = RegExp(r'^[0-9-+\s()]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return '올바른 전화번호 형식을 입력해주세요';
    }
    return null;
  }

  static String? validateFolderPath(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '저장 경로가 필요합니다';
    }

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(value)) {
      return '경로에 사용할 수 없는 문자가 포함되어 있습니다';
    }

    return null;
  }

  static String generateSafeFolderPath(String input, [String? parentPath]) {
    final safeName = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9가-힣\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    if (parentPath != null) {
      return '$parentPath/$safeName';
    }

    return safeName;
  }

  static List<String> parseTags(String? tagsString) {
    if (tagsString == null || tagsString.trim().isEmpty) {
      return [];
    }

    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
