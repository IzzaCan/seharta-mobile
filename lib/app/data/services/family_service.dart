import 'package:get/get.dart';
import '../providers/family_provider.dart';
import 'auth_service.dart';

class FamilyService extends GetxService {
  final FamilyProvider _familyProvider = FamilyProvider();
  final AuthService _authService = Get.find<AuthService>();

  final RxString familyName = ''.obs;

  static FamilyService get to => Get.find();

  Future<FamilyService> init() async {
    // Only fetch if user is logged in and has family_id
    if (_authService.isLoggedIn && _authService.currentUser.value?.familyId != null) {
      await fetchFamilyInfo();
    }
    
    // Listen to changes in current user (e.g., after login/logout/join family)
    ever(_authService.currentUser, (user) {
      if (user != null && user.familyId != null) {
        fetchFamilyInfo();
      } else {
        familyName.value = '';
      }
    });
    
    return this;
  }

  Future<void> fetchFamilyInfo() async {
    try {
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;
      final response = await _familyProvider.getFamilyInfo(token: token);
      familyName.value = response['family_name'];
    } catch (e) {
      print('Failed to fetch family info: $e');
    }
  }

  Future<void> updateFamilyName(String newName) async {
    try {
      final token = _authService.accessToken.value;
      final response = await _familyProvider.updateFamilyName(newName: newName, token: token);
      familyName.value = response['family_name'];
    } catch (e) {
      rethrow;
    }
  }
}
