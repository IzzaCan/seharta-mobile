import 'package:get/get.dart';
import '../data/models/notification_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/family_service.dart';
import '../modules/notifications/controllers/notification_controller.dart';

class ParsedNotification {
  final String categoryType; // 'TRANSACTION', 'OCR', 'BUDGET', 'WALLET', 'OTHER'
  final String title;
  final String message;
  
  // Transaction specific details
  final String? amount;
  final String? categoryName;
  final String? walletName;
  final String? description;
  final String? transactionType; // 'INCOME', 'EXPENSE'
  final String? actorName;
  
  // OCR specific
  final String? ocrTotal;
  final String? ocrMerchant;
  
  // Budget specific
  final String? budgetPercentage;
  final String? budgetRemaining;
  final String? budgetAmount;
  final String? budgetCategory;
  final bool isOverBudget;

  // Asset specific
  final String? assetName;

  // Goal specific
  final String? goalName;
  final String? goalTarget;
  final String? goalDeposit;

  ParsedNotification({
    required this.categoryType,
    required this.title,
    required this.message,
    this.amount,
    this.categoryName,
    this.walletName,
    this.description,
    this.transactionType,
    this.actorName,
    this.ocrTotal,
    this.ocrMerchant,
    this.budgetPercentage,
    this.budgetRemaining,
    this.budgetAmount,
    this.budgetCategory,
    this.isOverBudget = false,
    this.assetName,
    this.goalName,
    this.goalTarget,
    this.goalDeposit,
  });
}

ParsedNotification parseNotification(NotificationResponse item) {
  final titleLower = item.title.toLowerCase();
  final messageText = item.message;
  final messageLower = messageText.toLowerCase();
  
  // 1. Check if it's OCR / Scan Struk
  if (titleLower.contains('scan') || titleLower.contains('ocr') || messageLower.contains('struk')) {
    // Try to extract merchant and total
    String? total;
    String? merchant;
    
    final totalRegex = RegExp(r'(?:senilai|sebesar|total)\s+(Rp\s*[0-9.]+)', caseSensitive: false);
    final totalMatch = totalRegex.firstMatch(messageText);
    if (totalMatch != null) {
      total = totalMatch.group(1);
    }
    
    final merchantRegex = RegExp(r'struk\s+dari\s+([A-Za-z0-9 ]+)', caseSensitive: false);
    final merchantMatch = merchantRegex.firstMatch(messageText);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)?.trim();
    }
    
    return ParsedNotification(
      categoryType: 'OCR',
      title: '📸 Scan Struk Berhasil Diproses!',
      message: messageText,
      ocrTotal: total,
      ocrMerchant: merchant,
    );
  }
  
  // 2. Check if it's Budget Alert
  if (titleLower.contains('anggaran') || titleLower.contains('budget') || messageLower.contains('over-budget') || messageLower.contains('melebihi batas')) {
    final bool isOver = messageLower.contains('melebihi') || messageLower.contains('over-budget') || messageLower.contains('waduh');
    
    String? percentage;
    final pctRegex = RegExp(r'([0-9]+%)');
    final pctMatch = pctRegex.firstMatch(messageText);
    if (pctMatch != null) {
      percentage = pctMatch.group(1);
    }
    
    String? remaining;
    final remRegex = RegExp(r'tinggal\s+(Rp\s*[0-9.]+)', caseSensitive: false);
    final remMatch = remRegex.firstMatch(messageText);
    if (remMatch != null) {
      remaining = remMatch.group(1);
    }

    // Budget amount + category (covers "Anggaran Dibuat" / created notifications)
    String? amount;
    final amtRegex = RegExp(r'sebesar\s+(\d[\d.,]*)', caseSensitive: false);
    final amtMatch = amtRegex.firstMatch(messageText);
    if (amtMatch != null) {
      amount = 'Rp ${amtMatch.group(1)}';
    }

    String? category;
    final catRegex = RegExp(r"kategori\s+'([^']+)'", caseSensitive: false);
    final catMatch = catRegex.firstMatch(messageText);
    if (catMatch != null) {
      category = catMatch.group(1)?.trim();
    }

    // Extract category name if any e.g. "Kategori Makanan"
    String titleCategory = category ?? 'Umum';
    final catTitleRegex = RegExp(r'\((?:Kategori\s+)?([A-Za-z0-9 &]+)\)', caseSensitive: false);
    final catTitleMatch = catTitleRegex.firstMatch(item.title);
    if (catTitleMatch != null) {
      titleCategory = catTitleMatch.group(1) ?? 'Umum';
    }
    
    return ParsedNotification(
      categoryType: 'BUDGET',
      title: isOver ? '🚨 Anggaran Melebihi Batas!' : '⚠️ Peringatan Anggaran ($titleCategory)',
      message: messageText,
      budgetPercentage: percentage,
      budgetRemaining: remaining,
      budgetAmount: amount,
      budgetCategory: category,
      isOverBudget: isOver,
    );
  }

  // 2b. Check if it's Asset (created/edited)
  if (titleLower.contains('aset') || messageLower.contains("' telah ditambahkan") || messageLower.contains("' telah diperbarui")) {
    String? asset;
    final assetRegex = RegExp(r"'([^']+)'\s+(telah ditambahkan|telah diperbarui)", caseSensitive: false);
    final assetMatch = assetRegex.firstMatch(messageText);
    if (assetMatch != null) {
      asset = assetMatch.group(1)?.trim();
    }

    return ParsedNotification(
      categoryType: 'ASSET',
      title: '🏠 Aset Dibuat',
      message: messageText,
      assetName: asset,
    );
  }

  // 2c. Check if it's Goal (created) or Goal Contribution
  if (titleLower.contains('goal') || messageLower.contains('goal')) {
    String? gName;
    String? gTarget;
    String? gDeposit;

    final nameRegex = RegExp(r"Goal\s+'([^']+)'", caseSensitive: false);
    final nameMatch = nameRegex.firstMatch(messageText);
    if (nameMatch != null) gName = nameMatch.group(1)?.trim();

    final targetRegex = RegExp(r"target\s+(\d[\d.,]*)", caseSensitive: false);
    final targetMatch = targetRegex.firstMatch(messageText);
    if (targetMatch != null) gTarget = 'Rp ${targetMatch.group(1)!.trim()}';

    final depositRegex = RegExp(r"Deposit\s+(?:sebesar\s+)?(\d[\d.,]*)", caseSensitive: false);
    final depositMatch = depositRegex.firstMatch(messageText);
    if (depositMatch != null) gDeposit = 'Rp ${depositMatch.group(1)!.trim()}';

    final isContribution = messageLower.contains('deposit') || messageLower.contains('kontribusi');

    return ParsedNotification(
      categoryType: 'GOAL',
      title: isContribution ? '🎯 Kontribusi Goal (Deposit)' : '🎯 Goal Dibuat',
      message: messageText,
      goalName: gName,
      goalTarget: gTarget,
      goalDeposit: gDeposit,
    );
  }

  // 3. Check if it's Wallet Updates
  if (titleLower.contains('saldo') || titleLower.contains('dompet') || (item.metadataPayload != null && item.metadataPayload!.containsKey('wallet_id') && !item.metadataPayload!.containsKey('transaction_id'))) {
    String? wName;
    final wNameRegex = RegExp(r"Dompet\s+'([^']+)'", caseSensitive: false);
    final wNameMatch = wNameRegex.firstMatch(messageText);
    if (wNameMatch != null) {
      wName = wNameMatch.group(1)?.trim();
    }
    // fallback to payload
    wName ??= item.metadataPayload?['wallet_name'];

    return ParsedNotification(
      categoryType: 'WALLET',
      title: '💰 Pembaruan Saldo Dompet Bersama',
      message: messageText,
      walletName: wName,
    );
  }
  
  // 4. Check if it's Transaction (New, Edit, Delete)
  final isTxPayload = item.metadataPayload != null && item.metadataPayload!.containsKey('transaction_id');
  if (titleLower.contains('transaksi') || isTxPayload) {
    // Try custom template regex:
    // "Yusuf baru saja mencatat pengeluaran untuk Listrik & Air sebesar Rp 350.000 menggunakan Bank Mandiri (Joint). Keterangan: Token rumah bulan Juli."
    final customRegex = RegExp(
      r'^([A-Za-z0-9 ]+)\s+baru\s+saja\s+mencatat\s+(pengeluaran|pemasukan)\s+untuk\s+([A-Za-z0-9 &]+)\s+sebesar\s+(Rp\s*[0-9.]+|[0-9.]+)\s+menggunakan\s+([A-Za-z0-9 ()-]+)(?:\.\s+Keterangan:\s*(.*))?$',
      caseSensitive: false
    );
    
    final match = customRegex.firstMatch(messageText.trim());
    
    String? actor;
    String? type;
    String? cat;
    String? amt;
    String? wall;
    String? desc;
    
    if (match != null) {
      actor = match.group(1);
      type = match.group(2)?.toUpperCase() == 'PEMASUKAN' ? 'INCOME' : 'EXPENSE';
      cat = match.group(3);
      amt = match.group(4);
      wall = match.group(5);
      desc = match.group(6);
    } else {
      // Fallback parser for default backend template: "Transaksi EXPENSE sebesar 350000.0 telah ditambahkan."
      final fallbackRegex = RegExp(r'Transaksi\s+(EXPENSE|INCOME)\s+sebesar\s+([0-9.]+)\s+telah', caseSensitive: false);
      final fallbackMatch = fallbackRegex.firstMatch(messageText);
      if (fallbackMatch != null) {
        type = fallbackMatch.group(1)?.toUpperCase();
        final rawAmt = fallbackMatch.group(2);
        if (rawAmt != null) {
          // format amount to Rp
          final doubleVal = double.tryParse(rawAmt) ?? 0;
          amt = 'Rp ${doubleVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
        }
      }
      
      // Look for wallet name in payload if present
      if (item.metadataPayload != null) {
        wall = item.metadataPayload!['wallet_name'];
        cat = item.metadataPayload!['category_name'];
      }
    }
    
    // Lookup mapping from local controllers
    final notifController = Get.find<NotificationController>();
    if (wall == null && item.metadataPayload != null && item.metadataPayload!.containsKey('wallet_id')) {
      final wId = item.metadataPayload!['wallet_id']?.toString();
      if (wId != null) {
        wall = notifController.walletMap[wId];
      }
    }
    if (cat == null && item.metadataPayload != null && item.metadataPayload!.containsKey('category_id')) {
      final cId = item.metadataPayload!['category_id']?.toString();
      if (cId != null) {
        cat = notifController.categoryMap[cId];
      }
    }
    
    // Resolve dynamic title based on actor vs creator
    final authService = Get.find<AuthService>();
    final familyService = Get.find<FamilyService>();
    final currentUserId = authService.currentUser.value?.id.toString();
    
    final bool isCreator = item.actorUserId != null && item.actorUserId.toString() == currentUserId;
    
    String finalTitle = '✅ Transaksi Berhasil Dicatat';
    if (!isCreator) {
      final pName = familyService.partner?.fullName ?? actor ?? 'Pasangan';
      final isIncome = type == 'INCOME' || messageLower.contains('pemasukan');
      finalTitle = '📝 $pName mencatat ${isIncome ? "Pemasukan" : "Pengeluaran"} Baru!';
    }
    
    return ParsedNotification(
      categoryType: 'TRANSACTION',
      title: finalTitle,
      message: messageText,
      amount: amt,
      categoryName: cat,
      walletName: wall,
      description: desc ?? (match == null ? messageText : null),
      transactionType: type,
      actorName: actor,
    );
  }
  
  // Default fallback
  return ParsedNotification(
    categoryType: 'OTHER',
    title: item.title,
    message: messageText,
  );
}
