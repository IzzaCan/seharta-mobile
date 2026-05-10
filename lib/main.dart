import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Seharta",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D2B33),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D2B33),
          primary: const Color(0xFF0D2B33),
          secondary: const Color(0xFF1F9975),
        ),
      ),
    ),
  );
}
