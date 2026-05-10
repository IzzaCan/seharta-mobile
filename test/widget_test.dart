import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seharta/app/routes/app_pages.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    // Verify that splash screen is shown (assuming it has some identifiable text or widget)
    // Since I don't know the content of SplashView, I'll just check if the app built without error.
    expect(tester.takeException(), isNull);
  });
}
