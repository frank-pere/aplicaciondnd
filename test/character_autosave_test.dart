import 'package:dnd35_companion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('guarda la ficha y calcula los modificadores correctamente', (
    tester,
  ) async {
    await tester.pumpWidget(const DndCompanionApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final characterName = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Nombre del personaje',
    );
    expect(characterName, findsOneWidget);
    await tester.enterText(characterName, 'Arannis');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('character-sheet-v1'),
      contains('"character":"Arannis"'),
    );

    final strength = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Fuerza',
    );
    expect(strength, findsOneWidget);
    await tester.ensureVisible(strength);
    await tester.enterText(strength, '18');
    await tester.pump();
    expect(find.text('+4'), findsOneWidget);
    expect(find.text('—'), findsWidgets);

    await tester.enterText(strength, '9');
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);

    await tester.enterText(strength, '10');
    await tester.pump();
    expect(find.text('+0'), findsOneWidget);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText == 'Mod.' ||
                widget.decoration?.labelText == 'Temp.'),
      ),
      findsNothing,
    );

    final deityField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Deidad',
    );
    expect(deityField, findsOneWidget);
    await tester.ensureVisible(deityField);
    await tester.enterText(deityField, 'Eilistraee');
    await tester.pump(const Duration(milliseconds: 400));
    final deityPreferences = await SharedPreferences.getInstance();
    expect(
      deityPreferences.getString('character-sheet-v1'),
      contains('"deity":"Eilistraee"'),
    );

    final alignmentSelector = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Alineamiento',
    );
    expect(alignmentSelector, findsOneWidget);
    await tester.ensureVisible(alignmentSelector);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(alignmentSelector);
    await tester.pumpAndSettle();

    expect(find.text('Caótico Malvado'), findsOneWidget);
    expect(find.text('Neutral Puro'), findsOneWidget);
    await tester.tap(find.text('Legal Bueno').last);
    await tester.pumpAndSettle();

    expect(find.text('Legal Bueno'), findsWidgets);
    expect(find.text('LB'), findsOneWidget);
    expect(
      find.text(
        'Actúa como se espera de un individuo honorable y compasivo. Sigue el código, las leyes y la verdad para proteger a los inocentes y mantener el orden justo.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 350));

    final savedPreferences = await SharedPreferences.getInstance();
    expect(
      savedPreferences.getString('character-sheet-v1'),
      contains('"alignment":"Legal Bueno"'),
    );

    await tester.tap(find.byTooltip('Ver descripción del alineamiento'));
    await tester.pumpAndSettle();
    expect(find.text('Categoría moral'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
  });
}
