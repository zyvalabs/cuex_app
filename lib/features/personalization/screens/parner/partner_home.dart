import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../shop/controllers/product/product_controller.dart';
import '../../../shop/screens/home/widgets/home_appbar.dart';


class PartnerHome extends StatelessWidget {
  const PartnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -- Appbar
                THomeAppBar(),
                SizedBox(height: TSizes.spaceBtwSections),

                // /// -- Searchbar
                // // TSearchContainer(text: 'Search in Store', showBorder: false),
                // SizedBox(height: TSizes.spaceBtwSections),
                //
                // /// -- Categories
                // THeaderCategories(),
                // SizedBox(height: TSizes.spaceBtwSections * 2),
              ],
            ),

            /// -- Body
            Container(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // /// -- Promo Slider 1
                  // const TPromoSlider(),
                  // const SizedBox(height: TSizes.spaceBtwSections),
                  //
                  // /// -- Products Heading
                  // TSectionHeading(
                  //   title: TTexts.popularProducts,
                  //   onPressed: () => Get.to(
                  //         () => AllProducts(
                  //       title: TTexts.popularProducts,
                  //       futureMethod: ProductRepository.instance.getAllFeaturedProducts(),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: TSizes.spaceBtwItems),

                  // /// Products Section
                  // Obx(
                  //       () {
                  //     // Display loader while products are loading
                  //     if (controller.isLoading.value) return const TVerticalProductShimmer();
                  //
                  //     // Check if no featured products are found
                  //     if (controller.featuredProducts.isEmpty) {
                  //       return Center(child: Text('No Data Found!', style: Theme.of(context).textTheme.bodyMedium));
                  //     } else {
                  //       // Featured Products Found! 🎊
                  //       return TGridLayout(
                  //         itemCount: controller.featuredProducts.length,
                  //         itemBuilder: (_, index) =>
                  //             TProductCardVertical(product: controller.featuredProducts[index], isNetworkImage: true),
                  //       );
                  //     }
                  //   },
                  // ),

                  SizedBox(height: TDeviceUtils.getBottomNavigationBarHeight() + TSizes.defaultSpace),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
