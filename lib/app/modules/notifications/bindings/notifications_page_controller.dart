import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationsPageController extends GetxController {
  final NotificationController globalController = Get.find<NotificationController>();
  final ScrollController scrollController = ScrollController();
  
  final RxInt offset = 0.obs;
  final RxBool hasReachedMax = false.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _refreshData();
  }
  
  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _refreshData() async {
    offset.value = 0;
    hasReachedMax.value = false;
    await globalController.fetchAllNotifications(offset: 0, refresh: true);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        !hasReachedMax.value &&
        !globalController.isLoadingAll.value) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    isLoadingMore.value = true;
    offset.value += 20;
    int previousCount = globalController.allNotifications.length;
    
    await globalController.fetchAllNotifications(offset: offset.value, refresh: false);
    
    if (globalController.allNotifications.length == previousCount) {
      hasReachedMax.value = true;
    }
    isLoadingMore.value = false;
  }
  
  Future<void> onRefresh() async {
    await _refreshData();
  }
}
