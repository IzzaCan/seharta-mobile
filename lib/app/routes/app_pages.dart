import 'package:get/get.dart';

import '../modules/add_transaction/bindings/add_transaction_binding.dart';
import '../modules/add_transaction/views/add_transaction_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/change_pin/bindings/change_pin_binding.dart';
import '../modules/change_pin/views/change_pin_view.dart';
import '../modules/create_group/bindings/create_group_binding.dart';
import '../modules/create_group/views/create_group_view.dart';
import '../modules/edit_family_name/bindings/edit_family_name_binding.dart';
import '../modules/edit_family_name/views/edit_family_name_view.dart';
import '../modules/harta/bindings/harta_binding.dart';
import '../modules/harta/views/harta_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/join_group/bindings/join_group_binding.dart';
import '../modules/join_group/views/join_group_view.dart';
import '../modules/loading_ocr/bindings/loading_ocr_binding.dart';
import '../modules/loading_ocr/views/loading_ocr_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/manage_categories/bindings/manage_categories_binding.dart';
import '../modules/manage_categories/views/manage_categories_view.dart';
import '../modules/manage_wallets/bindings/manage_wallets_binding.dart';
import '../modules/manage_wallets/views/manage_wallets_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/scan_receipt/bindings/scan_receipt_binding.dart';
import '../modules/scan_receipt/views/scan_receipt_view.dart';
import '../modules/select_status/bindings/select_status_binding.dart';
import '../modules/select_status/views/select_status_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.SELECT_STATUS,
      page: () => const SelectStatusView(),
      binding: SelectStatusBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_GROUP,
      page: () => const CreateGroupView(),
      binding: CreateGroupBinding(),
    ),
    GetPage(
      name: _Paths.JOIN_GROUP,
      page: () => const JoinGroupView(),
      binding: JoinGroupBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ADD_TRANSACTION,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: _Paths.SCAN_RECEIPT,
      page: () => const ScanReceiptView(),
      binding: ScanReceiptBinding(),
    ),
    GetPage(
      name: _Paths.LOADING_OCR,
      page: () => const LoadingOcrView(),
      binding: LoadingOcrBinding(),
    ),
    GetPage(
      name: _Paths.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: _Paths.HARTA,
      page: () => const HartaView(),
      binding: HartaBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_FAMILY_NAME,
      page: () => const EditFamilyNameView(),
      binding: EditFamilyNameBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_CATEGORIES,
      page: () => const ManageCategoriesView(),
      binding: ManageCategoriesBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_WALLETS,
      page: () => const ManageWalletsView(),
      binding: ManageWalletsBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PIN,
      page: () => const ChangePinView(),
      binding: ChangePinBinding(),
    ),
  ];
}
