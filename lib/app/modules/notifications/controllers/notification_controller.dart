import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';

class NotificationController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<NotificationResponse> recentNotifications = <NotificationResponse>[].obs;
  final RxList<NotificationResponse> allNotifications = <NotificationResponse>[].obs;
  final RxBool hasUnread = false.obs;
  final RxInt unreadCount = 0.obs;
  
  final RxBool isLoadingRecent = false.obs;
  final RxBool isLoadingAll = false.obs;
  
  final RxBool isPushEnabled = true.obs;
  static const String _pushPrefKey = 'is_push_notifications_enabled';

  final RxMap<String, String> walletMap = <String, String>{}.obs;
  final RxMap<String, String> categoryMap = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPushSetting();
    // Re-fetch notifications when token changes (user logs in/out)
    ever(_authService.accessToken, (token) {
      if (token.isNotEmpty) {
        fetchRecentNotifications();
        fetchUnreadCount();
        fetchMetadataLookups();
      } else {
        clearData();
      }
    });
    
    // Initial fetch if already logged in
    if (_authService.accessToken.value.isNotEmpty) {
      fetchRecentNotifications();
      fetchUnreadCount();
      fetchMetadataLookups();
    }
  }

  void clearData() {
    recentNotifications.clear();
    allNotifications.clear();
    hasUnread.value = false;
    unreadCount.value = 0;
    walletMap.clear();
    categoryMap.clear();
  }

  Future<void> _loadPushSetting() async {
    final prefs = await SharedPreferences.getInstance();
    isPushEnabled.value = prefs.getBool(_pushPrefKey) ?? true;
  }

  Future<void> togglePushSetting(bool value) async {
    isPushEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushPrefKey, value);
    // TODO: Send to backend when endpoint is ready
    if (kDebugMode) print('Mock: Notification settings changed to $value');
  }

  Future<void> fetchRecentNotifications() async {
    if (isLoadingRecent.value) return;
    try {
      isLoadingRecent.value = true;
      final response = await _apiProvider.getNotifications(
        token: _authService.accessToken.value,
        limit: 5,
      );
      final paginated = NotificationPaginatedResponse.fromJson(response);
      recentNotifications.assignAll(paginated.items);
      _updateUnreadStatus();
    } catch (e) {
      if (kDebugMode) print('Error fetching recent notifications: $e');
    } finally {
      isLoadingRecent.value = false;
    }
  }

  Future<void> fetchMetadataLookups() async {
    try {
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;
      
      // Fetch wallets
      final walletRes = await _apiProvider.get('/wallets/', token: token);
      final List<dynamic> walletsData = walletRes['data'] ?? [];
      for (var w in walletsData) {
        final id = w['id']?.toString();
        final name = w['wallet_name']?.toString() ?? w['name']?.toString();
        if (id != null && name != null) {
          walletMap[id] = name;
        }
      }
      
      // Fetch categories
      final categoryRes = await _apiProvider.get('/categories/', token: token);
      final List<dynamic> categoriesData = categoryRes is Map && categoryRes.containsKey('data') 
          ? categoryRes['data'] 
          : categoryRes;
      for (var c in categoriesData) {
        final id = c['id']?.toString();
        final name = c['name']?.toString();
        if (id != null && name != null) {
          categoryMap[id] = name;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading metadata lookups in NotificationController: $e');
    }
  }

  Future<void> fetchAllNotifications({int offset = 0, bool refresh = false}) async {
    if (isLoadingAll.value) return;
    try {
      isLoadingAll.value = true;
      if (refresh) allNotifications.clear();
      
      final response = await _apiProvider.getNotifications(
        token: _authService.accessToken.value,
        limit: 20,
        offset: offset,
      );
      final paginated = NotificationPaginatedResponse.fromJson(response);
      
      if (refresh) {
        allNotifications.assignAll(paginated.items);
      } else {
        allNotifications.addAll(paginated.items);
      }
      
      _updateUnreadStatus();
    } catch (e) {
      if (kDebugMode) print('Error fetching all notifications: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiProvider.getNotificationUnreadCount(
        token: _authService.accessToken.value,
      );
      final count = response['unread_count'] as int? ?? 0;
      
      final localUnreadCount = recentNotifications.where((n) => !n.isRead).length;
      
      unreadCount.value = count > localUnreadCount ? count : localUnreadCount;
      hasUnread.value = unreadCount.value > 0;
    } catch (e) {
      if (kDebugMode) print('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiProvider.markNotificationAsRead(
        notificationId: id,
        token: _authService.accessToken.value,
      );
      
      // Update local state
      _markLocalAsRead(id);
      
      if (unreadCount.value > 0) {
        unreadCount.value--;
        hasUnread.value = unreadCount.value > 0;
      }
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
    }
  }
  
  void _markLocalAsRead(String id) {
    int recentIndex = recentNotifications.indexWhere((n) => n.id == id);
    if (recentIndex != -1) {
      var n = recentNotifications[recentIndex];
      recentNotifications[recentIndex] = _copyWithRead(n);
    }
    
    int allIndex = allNotifications.indexWhere((n) => n.id == id);
    if (allIndex != -1) {
      var n = allNotifications[allIndex];
      allNotifications[allIndex] = _copyWithRead(n);
    }
  }
  
  NotificationResponse _copyWithRead(NotificationResponse n) {
    return NotificationResponse(
      id: n.id,
      familyId: n.familyId,
      actorUserId: n.actorUserId,
      title: n.title,
      message: n.message,
      type: n.type,
      priority: n.priority,
      isRead: true,
      metadataPayload: n.metadataPayload,
      createdAt: n.createdAt,
      updatedAt: n.updatedAt,
    );
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiProvider.markAllNotificationsAsRead(
        token: _authService.accessToken.value,
      );
      
      // Update local states
      for (int i = 0; i < recentNotifications.length; i++) {
        recentNotifications[i] = _copyWithRead(recentNotifications[i]);
      }
      for (int i = 0; i < allNotifications.length; i++) {
        allNotifications[i] = _copyWithRead(allNotifications[i]);
      }
      
      unreadCount.value = 0;
      hasUnread.value = false;
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications as read: $e');
    }
  }

  void _updateUnreadStatus() {
    final localCount = recentNotifications.where((n) => !n.isRead).length;
    if (localCount > unreadCount.value) {
      unreadCount.value = localCount;
    }
    hasUnread.value = unreadCount.value > 0;
  }
}
