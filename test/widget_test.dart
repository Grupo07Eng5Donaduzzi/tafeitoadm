import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tafeitoadm/src/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows admin login', (tester) async {
    await tester.pumpWidget(const TaFeitoAdminApp());
    await tester.pump();

    expect(find.text('Entrar'), findsOneWidget);
  });
}
