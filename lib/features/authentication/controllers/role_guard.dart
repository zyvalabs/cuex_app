import 'package:flutter/cupertino.dart';

import '../../../utils/constants/enums.dart';
import '../../personalization/controllers/user_controller.dart';
class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.roles, required this.child});

  final List<AppRole> roles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = UserController.instance.user.value;
    return roles.contains(user.role) ? child : const SizedBox.shrink();
  }
}