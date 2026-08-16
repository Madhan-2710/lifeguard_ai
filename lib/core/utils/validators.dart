/// Form validation helpers for LifeGuard AI
class Validators {
  Validators._();

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 32) {
      return 'Password must be less than 32 characters';
    }
    return null;
  }

  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates medicine name
  static String? validateMedicineName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter medicine name';
    }
    if (value.trim().length < 2) {
      return 'Medicine name must be at least 2 characters';
    }
    return null;
  }

  /// Validates dosage
  static String? validateDosage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter dosage';
    }
    return null;
  }

  /// Validates contact name
  static String? validateContactName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter contact name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates contact phone number
  static String? validateContactPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates emergency instructions
  static String? validateEmergencyInstructions(String? value) {
    if (value != null && value.length > 500) {
      return 'Instructions must be less than 500 characters';
    }
    return null;
  }

  /// Validates blood type
  static String? validateBloodType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!bloodTypes.contains(value.trim().toUpperCase())) {
      return 'Please select a valid blood type';
    }
    return null;
  }

  /// Validates chat message
  static String? validateChatMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please type a message';
    }
    if (value.trim().length > 1000) {
      return 'Message must be less than 1000 characters';
    }
    return null;
  }

  /// Validates a required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

