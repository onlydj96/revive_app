enum UserRole {
  admin('Admin'),
  member('Member');

  const UserRole(this.displayName);
  
  final String displayName;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'member':
      default:
        return UserRole.member;
    }
  }

  bool get canCreateContent => this == UserRole.admin;
  bool get canEditContent => this == UserRole.admin;
  bool get canDeleteContent => this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
  bool get canViewContent => true; // All users can view content
}