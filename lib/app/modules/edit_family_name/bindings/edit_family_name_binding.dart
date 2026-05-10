import 'package:get/get.dart';

import '../controllers/edit_family_name_controller.dart';

class EditFamilyNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditFamilyNameController>(
      () => EditFamilyNameController(),
    );
  }
}
