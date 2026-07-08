class NotificationResponse {
  final String id;
  final String familyId;
  final String? actorUserId;
  final String title;
  final String message;
  final String type;
  final String? priority;
  final bool isRead;
  final Map<String, dynamic>? metadataPayload;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationResponse({
    required this.id,
    required this.familyId,
    this.actorUserId,
    required this.title,
    required this.message,
    required this.type,
    this.priority,
    required this.isRead,
    this.metadataPayload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'] ?? '',
      familyId: json['family_id'] ?? '',
      actorUserId: json['actor_user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'NOTIFICATION',
      priority: json['priority'],
      isRead: json['is_read'] ?? false,
      metadataPayload: json['metadata_payload'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'actor_user_id': actorUserId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'is_read': isRead,
      'metadata_payload': metadataPayload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NotificationPaginatedResponse {
  final List<NotificationResponse> items;
  final int total;
  final int limit;
  final int offset;

  NotificationPaginatedResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory NotificationPaginatedResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<NotificationResponse> itemsList =
        list.map((i) => NotificationResponse.fromJson(i)).toList();

    return NotificationPaginatedResponse(
      items: itemsList,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 100,
      offset: json['offset'] ?? 0,
    );
  }
}
