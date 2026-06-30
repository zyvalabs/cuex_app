
import 'package:flutter/cupertino.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/cloud_helper_functions.dart';
import '../layouts/list_layout.dart';
import '../shimmers/vertical_product_shimmer.dart';
import '../texts/section_heading.dart';

class TEventFilteredTab extends StatelessWidget {
  const TEventFilteredTab({
    super.key,
    required this.title,
    required this.futureMethod,
    required this.itemBuilder,
  });

  final String title;
  final Future<List<dynamic>> futureMethod;
  final Widget Function(BuildContext, int, dynamic) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FutureBuilder(
          future: futureMethod,
          builder: (context, snapshot) {
            final response = TCloudHelperFunctions.checkMultiRecordState(
              snapshot: snapshot,
              loader: const TVerticalProductShimmer(),
            );
            if (response != null) return response;

            final items = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TSectionHeading(title: title, showActionButton: false),
                const SizedBox(height: TSizes.spaceBtwItems),
                TListLayout(
                  itemCount: items.length,
                  itemBuilder: (context, index) => itemBuilder(context, index, items[index]),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
