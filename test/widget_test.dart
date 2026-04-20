import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:persaka_hackathon_app/features/auth/password_auth/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders core actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
