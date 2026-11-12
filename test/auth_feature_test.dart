import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/features/auth/login_screen.dart';
import 'package:uku_app/features/auth/register_screen.dart';

void main() {
  testWidgets('login password visibility can be toggled', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    EditableText passwordField() => tester.widget<EditableText>(
          find.byType(EditableText).last,
        );

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);

    await tester.tap(find.byTooltip('Sembunyikan password'));
    await tester.pump();
    expect(passwordField().obscureText, isTrue);
  });

  testWidgets('registration returns to login and password visibility toggles',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.byKey(const ValueKey('open-register')));
    await tester.pumpAndSettle();

    expect(find.byType(Register), findsOneWidget);
    final passwordFields = find.byType(EditableText);
    expect(tester.widget<EditableText>(passwordFields.at(2)).obscureText, isTrue);
    expect(tester.widget<EditableText>(passwordFields.at(3)).obscureText, isTrue);

    await tester.tap(find.byTooltip('Tampilkan password').first);
    await tester.pump();
    expect(tester.widget<EditableText>(passwordFields.at(2)).obscureText, isFalse);
    expect(tester.widget<EditableText>(passwordFields.at(3)).obscureText, isFalse);

    await tester.tap(find.text('Sudah punya akun? Kembali ke Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login ke Akun Kamu'), findsOneWidget);
  });
}
