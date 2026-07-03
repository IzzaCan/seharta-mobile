import 'package:get/get.dart';
import '../../harta/models/asset_model.dart';
import '../../../data/services/auth_service.dart';
import '../../harta/controllers/harta_controller.dart';
import '../../../data/providers/api_provider.dart';

class DetailAssetController extends GetxController {
  late AssetModel asset;
  final AuthService _authService = Get.find<AuthService>();
  final ApiProvider _apiProvider = ApiProvider();

  // Observable for any loading state (e.g., deleting)
  final isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Expect AssetModel to be passed via arguments
    asset = Get.arguments as AssetModel;
  }

  // Getter for current user ID
  String get currentUserId => _authService.currentUser.value?.id ?? '';

  // Getter for mutate access
  bool get canEdit {
    if (asset.ownershipType == 'JOINT') return true;
    return currentUserId == asset.ownerUserId;
  }

  // Parses photo_url into a list of strings
  List<String> get photoUrls {
    if (asset.photoUrl == null || asset.photoUrl!.trim().isEmpty) return [];
    return asset.photoUrl!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((url) => '${ApiProvider.baseDomain}$url')
        .toList();
  }

  // Getter for main photo
  String? get mainPhotoUrl {
    final urls = photoUrls;
    if (urls.isNotEmpty) return urls.first;
    return null;
  }

  // Getter for document photos
  List<String> get documentUrls {
    final urls = photoUrls;
    if (urls.length > 1) {
      return urls.sublist(1);
    }
    return [];
  }

  // Delete asset function
  Future<void> deleteAsset() async {
    try {
      isDeleting(true);
      final token = _authService.accessToken.value;
      await _apiProvider.deleteAsset(id: asset.id, token: token);
      
      // Refresh list on Harta View
      if (Get.isRegistered<HartaController>()) {
        Get.find<HartaController>().fetchAssets();
      }
      
      Get.back(); // close dialog or view
      Get.snackbar('Berhasil', 'Aset berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus aset');
    } finally {
      isDeleting(false);
    }
  }
}
