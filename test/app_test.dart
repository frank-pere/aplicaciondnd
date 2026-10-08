import 'package:dnd35_companion/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('carga la ficha y busca conjuros del compendio local',
      (tester) async {
    await tester.pumpWidget(const DndCompanionApp());
    await tester.pumpAndSettle();

    expect(find.text('66 CONJUROS'), findsOneWidget);

    await tester.tap(find.text('Conjuros').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Bola de fuego');
    await tester.pumpAndSettle();

    expect(find.text('1 de 66 conjuros'), findsOneWidget);
    expect(find.text('Bola de fuego (Fireball)'), findsOneWidget);
  });
}
