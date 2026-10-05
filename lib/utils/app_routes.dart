import 'package:flutter/material.dart';

import '../screens/admin/approve_venue_screen.dart';
import '../screens/admin/manage_promotion_screen.dart';
import '../screens/admin/statistics_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/booking_confirmation_screen.dart';
import '../screens/customer/booking_history_screen.dart';
import '../screens/customer/booking_screen.dart';
import '../screens/customer/customer_promotion_screen.dart';
import '../screens/customer/customer_shell.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/payment_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/venue_detail_screen.dart';
import '../screens/owner/manage_service_screen.dart';
import '../screens/owner/manage_venue_screen.dart';
import '../screens/owner/upload_venue_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Auth
  static const login = '/login';
  static const register = '/register';

  // Customer shell (BottomNavigationBar host)
  static const customerShell = '/customer';

  // Customer flow screens (navigated on top of shell stack)
  static const home = '/home';
  static const search = '/search';
  static const venueDetail = '/venue-detail';
  static const booking = '/booking';
  static const bookingConfirmation = '/booking-confirmation';
  static const payment = '/payment';
  static const bookingHistory = '/booking-history';
  static const customerPromotion = '/promotions';
  static const profile = '/profile';

  // Owner
  static const uploadVenue = '/upload-venue';
  static const manageVenue = '/manage-venue';
  static const manageService = '/manage-service';

  // Admin
  static const approveVenue = '/approve-venue';
  static const managePromotion = '/manage-promotion';
  static const statistics = '/statistics';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),

        // Customer shell: hosts Home / Search / Promotions / History / Profile
        customerShell: (ctx) {
          final tabIndex =
              ModalRoute.of(ctx)?.settings.arguments as int? ?? 0;
          return CustomerShell(initialIndex: tabIndex);
        },

        // Standalone screens used in navigation flow on top of shell
        home: (_) => const HomeScreen(),
        search: (_) => const SearchScreen(),
        venueDetail: (_) => const VenueDetailScreen(),
        booking: (_) => const BookingScreen(),
        bookingConfirmation: (_) => const BookingConfirmationScreen(),
        payment: (_) => const PaymentScreen(),
        bookingHistory: (_) => const BookingHistoryScreen(),
        customerPromotion: (_) => const CustomerPromotionScreen(),
        profile: (_) => const ProfileScreen(),

        // Owner
        uploadVenue: (_) => const UploadVenueScreen(),
        manageVenue: (_) => const ManageVenueScreen(),
        manageService: (_) => const ManageServiceScreen(),

        // Admin
        approveVenue: (_) => const ApproveVenueScreen(),
        managePromotion: (_) => const ManagePromotionScreen(),
        statistics: (_) => const StatisticsScreen(),
      };
}
