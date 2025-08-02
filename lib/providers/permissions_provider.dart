import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'user_provider.dart';

final permissionsProvider = Provider<PermissionsController>((ref) {
  final user = ref.watch(userProvider);
  return PermissionsController(user);
});

class PermissionsController {
  final User? _user;

  PermissionsController(this._user);

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get canCreateContent => _user?.canCreateContent ?? false;
  bool get canEditContent => _user?.canEditContent ?? false;
  bool get canDeleteContent => _user?.canDeleteContent ?? false;
  bool get canManageUsers => _user?.canManageUsers ?? false;
  bool get canViewContent => _user?.canViewContent ?? false;

  bool canEditPost(String? authorId) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    return _user?.id == authorId;
  }

  bool canDeletePost(String? authorId) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    return _user?.id == authorId;
  }

  bool canDeleteFolder(String? createdBy) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    return _user?.id == createdBy;
  }

  bool canDeleteMedia(String? createdBy) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    return _user?.id == createdBy;
  }

  UserRole get userRole => _user?.userRole ?? UserRole.member;
  User? get currentUser => _user;
}