import 'package:dnd35_companion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('carga la ficha y busca conjuros del compendio local', (
    tester,
  ) async {
    await tester.pumpWidget(const DndCompanionApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('66 CONJUROS'), findsOneWidget);

    await tester.tap(find.text('Conjuros').first);
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Buscar conjuros',
    );
    await tester.enterText(search, 'Bola de fuego');
    await tester.pumpAndSettle();

    expect(find.text('1 de 66 conjuros'), findsOneWidget);
    expect(find.text('Bola de fuego (Fireball)'), findsOneWidget);

    final levelFilter = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<int?>,
    );
    await tester.tap(levelFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nivel 3').last);
    await tester.pumpAndSettle();
    expect(find.text('1 de 66 conjuros'), findsOneWidget);

    await tester.tap(find.text('Bola de fuego (Fireball)'));
    await tester.pumpAndSettle();
    expect(find.text('Mago/Hechicero 3'), findsOneWidget);
    expect(find.text('Evocación'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });
}
