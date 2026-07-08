String formatTimeAgo(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(local);

  if (difference.inSeconds < 60) {
    return 'baru saja';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes menit yang lalu';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours jam yang lalu';
  } else {
    final days = difference.inDays;
    return '$days hari yang lalu';
  }
}

String formatFullDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  
  final months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final dateString = '${local.day} ${months[local.month - 1]} ${local.year}';
  final timeString = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  
  final relative = formatTimeAgo(dateTime);
  
  return '$dateString, $timeString ($relative)';
}

