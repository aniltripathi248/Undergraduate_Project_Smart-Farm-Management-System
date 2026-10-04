import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_management_system/app.dart';

void main() {
  testWidgets('App renders splash screen and SFMS branding', (
    WidgetTester tester,
  ) async {
    // Build app
    await tester.pumpWidget(const SmartFarmApp());

    // Verify splash screen branding is displayed
    expect(find.text('Smart Farm'), findsOneWidget);
    expect(find.text('Management System (SFMS)'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump timer to navigate to login screen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify login screen elements are now rendered
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
