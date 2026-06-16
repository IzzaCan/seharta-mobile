import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../providers/wallet_provider.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
