import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/faq/faq_screen.dart';
import 'package:uku_app/features/home/home_screen.dart';
import 'package:uku_app/features/profile/about_us_screen.dart';

void main() {
  testWidgets('FAQ back button matches About Us back button position',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: FaqScreen()));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    final faqBackPosition = tester.getCenter(find.byTooltip('Kembali'));

    await tester.pumpWidget(const MaterialApp(home: AboutUsScreen()));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    final aboutBackPosition = tester.getCenter(find.byTooltip('Kembali'));

    expect(faqBackPosition.dx, aboutBackPosition.dx);
    expect(faqBackPosition.dy, aboutBackPosition.dy);
  });

  testWidgets('home page does not show the FAQ section', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(
            store: UkuStore(),
            onExpense: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pertanyaan Umum'), findsNothing);
    expect(find.text('Lihat Semua'), findsNothing);
  });

  testWidgets('FAQ page expands one question at a time', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: FaqScreen()),
    );

    expect(tester.getCenter(find.text('FAQ')).dy, closeTo(82.5, 0.5));
    expect(
      find.text('Intelligent Personal Finance & Budget Manager'),
      findsNothing,
    );
    expect(find.byType(Image), findsNothing);
    expect(find.text('Pertanyaan Umum'), findsOneWidget);
    await tester.tap(find.text('Apa itu UKU App?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('UKU adalah aplikasi'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.text('Bagaimana cara mengatur budget bulanan?'),
    );
    await tester.tap(find.text('Bagaimana cara mengatur budget bulanan?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('UKU adalah aplikasi'), findsNothing);
    expect(find.textContaining('Buka menu Budget'), findsOneWidget);

    expect(
      find.text('Bagaimana cara mencatat pengeluaran dari bill?'),
      findsOneWidget,
    );
    expect(find.text('Butuh bantuan lainnya?'), findsOneWidget);
  });
}
