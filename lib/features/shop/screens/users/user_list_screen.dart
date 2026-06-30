import 'package:cuex_app/features/shop/screens/users/widgets/search_bar.dart';
import 'package:cuex_app/features/shop/screens/users/widgets/user-tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../../personalization/screens/profile/user_detail_screen.dart';
import '../../controllers/user_list_controller.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key, this.roleFilter});
  final AppRole? roleFilter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminUserController(roleFilter: roleFilter));
    final search = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          roleFilter == AppRole.partner
              ? 'Partners'
              : roleFilter == AppRole.player
              ? 'Players'
              : 'All Users',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TSearchBar(
              hint: 'Search by name or email...',
              onChanged: (val) => search.value = val.toLowerCase(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

              final filtered = controller.users.where((u) {
                final q = search.value;
                return u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
              }).toList();

              if (filtered.isEmpty) return const Center(child: Text('No users found'));

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (_, i) => UserListTile(
                  user: filtered[i],
                  onTap: () => Get.to(() => UserDetailScreen(userId: filtered[i].id)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}