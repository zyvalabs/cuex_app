import 'package:cuex_app/bindings/user_binding.dart';
import 'package:cuex_app/features/shop/screens/events/venue_events_screen.dart';
import 'package:cuex_app/features/shop/screens/live_scroring/live_scoring.dart';
import 'package:cuex_app/features/shop/screens/matches/match_detail.dart';
import 'package:cuex_app/features/shop/screens/streaming/cuex_cam_promotion.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../bindings/completed_matches_binding.dart';
import '../bindings/coupon_binding.dart';
import '../bindings/live_streaming_binding.dart';
import '../bindings/sign_in_binding.dart';
import '../bindings/table_binding.dart';
import '../bindings/venue_binding.dart';
import '../features/authentication/screens/login/login.dart';
import '../features/authentication/screens/onboarding/onboarding.dart';
import '../features/authentication/screens/otp/otp_screen.dart';
import '../features/authentication/screens/password_configuration/forget_password.dart';
import '../features/authentication/screens/phone_number/phone_number_screen.dart';
import '../features/authentication/screens/pin/register_pin_screen.dart';
import '../features/authentication/screens/pin/update_pin_screen.dart';
import '../features/authentication/screens/pin/verify_pin_screen.dart';
import '../features/authentication/screens/signup/signup.dart';
import '../features/authentication/screens/signup/verify_email.dart';
import '../features/authentication/screens/welcome/welcome_screen.dart';

import '../features/personalization/screens/address/add_new_address.dart';
import '../features/personalization/screens/address/address.dart';
import '../features/personalization/screens/profile/profile.dart';
import '../features/personalization/screens/setting/settings.dart';
import '../features/shop/models/match_model.dart';
import '../features/shop/screens/bookings/my_bookings_screen.dart';
import '../features/shop/screens/coupon/coupon_screen.dart';
import '../features/shop/screens/events/add_event_screen.dart';
import '../features/shop/screens/events/events_screen.dart';
import '../features/shop/screens/favourites/favourite.dart';
import '../features/shop/screens/home/home_screen.dart';
import '../features/shop/screens/live streaming pedro/presentation/screens/LiveStreamingScreen.dart';
import '../features/shop/screens/matches/completed_matches.dart';

import '../features/shop/screens/promotion/promotion_list.dart';
import '../features/shop/screens/search/search.dart';
import '../features/shop/screens/store/store.dart';
import '../features/shop/screens/table/table_details_screen.dart';
import '../features/shop/screens/table/table_screen.dart';
import '../features/shop/screens/venues/venue_screen.dart';
import '../home_menu.dart';
import 'routes.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: TRoutes.phoneSignIn, page: () => const PhoneNumberScreen(), binding: SignInBinding()),
    GetPage(name: TRoutes.home, page: () => const HomeScreen()),
    // GetPage(name: TRoutes.homeMenu, page: () => const HomeMenu()),
    GetPage(name: TRoutes.store, page: () => const StoreScreen()),
    GetPage(name: TRoutes.favourites, page: () => const FavouriteScreen()),
    GetPage(name: TRoutes.settings,      binding: UserBinding(), page: () => const SettingsScreen()),
    GetPage(name: TRoutes.search, page: () => SearchScreen()),
    GetPage(name: TRoutes.matchDetails, page: () {
      final match = Get.arguments as MatchModel;
      return MatchDetailScreen(match: match);
    }),
    // GetPage(name: TRoutes.productReviews, page: () => const ProductReviewsScreen()),
    // GetPage(name: TRoutes.order, page: () => const OrderScreen()),
    // GetPage(name: TRoutes.orderDetail, page: () => const OrderDetail()),
    // GetPage(name: TRoutes.checkout, page: () => const CheckoutScreen()),
    // GetPage(name: TRoutes.cart, page: () => const CartScreen()),
    GetPage(name: TRoutes.userProfile, page: () => const ProfileScreen()),
    GetPage(name: TRoutes.userAddress, page: () => const UserAddressScreen()),
    GetPage(name: TRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: TRoutes.verifyEmail, page: () => const VerifyEmailScreen()),
    GetPage(name: TRoutes.logIn, page: () => const LoginScreen()),
    GetPage(name: TRoutes.forgetPassword, page: () => const ForgetPasswordScreen()),
    GetPage(name: TRoutes.onBoarding, page: () => const OnBoardingScreen()),
    GetPage(name: TRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: TRoutes.events, page: () => const EventsScreen()),
    GetPage(name: TRoutes.pin, page: () => const RegisterPinScreen()),
    GetPage(name: TRoutes.verifyPin, page: () => const VerifyPinScreen()),
    GetPage(name: TRoutes.updatePin, page: () => const UpdatePinScreen()),
    GetPage(name: TRoutes.otpVerification, page: () => const OtpScreen()),
    GetPage(name: TRoutes.venues, page: () => const VenueScreen(), binding: VenueBinding(), transition: Transition.fade),
    GetPage(name: TRoutes.addEvents, page: () => AddEventScreen(venueId: Get.arguments)),
    GetPage(name: TRoutes.tables, page: () => TablesScreen(venue: Get.arguments), binding: TablesBinding(), transition: Transition.fade),
    GetPage(name: TRoutes.myBookings, page: () => const MyBookingsScreen(), transition: Transition.fade),
    GetPage(
      name: TRoutes.completedMatches,
      page: () => const CompletedMatchesScreen(),
      binding: CompletedMatchesBinding(),
      transition: Transition.fade,
    ),
    GetPage(name: TRoutes.promoManagement, page: () => const PromoManagementScreen()),

    GetPage(name: TRoutes.coupon, page: () => const CouponsScreen(), binding: CouponBinding(), transition: Transition.fade),

    GetPage(name: TRoutes.addNewAddress, page: () => const AddNewAddressScreen(), transition: Transition.fade),
    GetPage(name: TRoutes.tableDetail, page: () => TableDetailScreen(table: Get.arguments), transition: Transition.fade),

    /// Chats
    // GetPage(name: TRoutes.chatList, page: () => const ChatListScreen()),
    // GetPage(name: TRoutes.chat, page: () => ChatScreen()),
    GetPage(
      name: TRoutes.liveStreaming,
      page: () => LiveStreamingScreen(match: Get.arguments as MatchModel),
      binding: LiveStreamingBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.livePromotion,
      page: () => PlayerLiveStreamingScreen(),
      // binding: LiveStreamingBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.liveScoring,
      page: () => LiveScoringScreen(match: Get.arguments as MatchModel),
      binding: LiveStreamingBinding(),
      transition: Transition.fade,
    ),
    // GetPage(
    //   name: TRoutes.notification,
    //   page: () => const NotificationScreen(),
    //   binding: NotificationBinding(),
    //   transition: Transition.fade,
    // ),
    // GetPage(
    //   name: TRoutes.notificationDetails,
    //   page: () => const NotificationDetailScreen(),
    //   binding: NotificationBinding(),
    //   transition: Transition.fade,
    // ),
  ];
}
