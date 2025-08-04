class FormValidators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필드'}를 입력해주세요';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필드'}를 입력해주세요';
    }
    if (value.trim().length < minLength) {
      return '${fieldName ?? '필드'}는 최소 $minLength글자 이상이어야 합니다';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? '필드'}는 최대 $maxLength글자까지 입력 가능합니다';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다';
    }
    return null;
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