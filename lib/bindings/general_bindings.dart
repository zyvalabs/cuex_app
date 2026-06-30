import 'package:get/get.dart';

import '../data/repositories/events/event_repository.dart';
import '../data/services/notifications/notification_service.dart';
import '../features/authentication/controllers/otp_controller.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/notifcation_controller.dart';
import '../features/personalization/controllers/settings_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../features/shop/controllers/categories_controller.dart';
import '../features/shop/controllers/coupon_controller.dart';
import '../features/shop/controllers/event_controller.dart';
import '../features/shop/controllers/high_break.dart';

import '../features/shop/controllers/matches_controller.dart';
import '../features/shop/controllers/news_controller.dart';
import '../features/shop/controllers/product/favourites_controller.dart';
import '../features/shop/controllers/product/images_controller.dart';
import '../features/shop/controllers/product/variation_controller.dart';
import '../features/shop/controllers/promotion_controller.dart';
import '../features/shop/controllers/venue_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.put(NetworkManager());

    /// -- Product
    Get.put(VariationController());
    Get.put(ImagesController());
    Get.put(VenueController());
    Get.put(EventRepository());

    /// -- Other
    Get.put(AddressController());
    Get.put(TNotificationService());

    /// -- Lazy — recreated if disposed (fenix: true prevents "not found" errors)
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => VariationController(), fenix: true);
    Get.lazyPut(() => CouponController(), fenix: true);
    Get.lazyPut(() => OTPController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => FavouriteController(), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);

    /// -- CueX controllers
    Get.lazyPut(() => EventController(), fenix: true);
    Get.lazyPut(() => MatchController(), fenix: true);
    Get.lazyPut(() => NewsController(), fenix: true);
    Get.lazyPut(() => HighestBreaksController(), fenix: true);
    Get.lazyPut(() => PromotionController(), fenix: true);
  }
}