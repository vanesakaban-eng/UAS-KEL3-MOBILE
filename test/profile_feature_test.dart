import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/features/profile/edit_profil.dart';

void main() {
  testWidgets('profile edit matches the requested form layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: EditProfileScreen()),
    );

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('type here'), findsNWidgets(5));
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.widgetWithText(ElevatedButton, 'LOGOUT'), findsOneWidget);

    final password = tester.widget<EditableText>(
      find.byType(EditableText).at(3),
    );
    expect(password.obscureText, isTrue);

    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(3)).obscureText,
      isFalse,
    );
  });
}
