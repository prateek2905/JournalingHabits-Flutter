import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:journaling_habits/main.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('App renders without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const JournalingHabitsApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
