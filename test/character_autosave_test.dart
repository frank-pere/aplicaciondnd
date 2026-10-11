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

    final deityField = find.text('Seleccionar deidad');
    await tester.scrollUntilVisible(
      deityField,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(deityField);
    await tester.pumpAndSettle();
    expect(find.text('75 de 75 deidades'), findsOneWidget);
    expect(find.text('D&D'), findsWidgets);

    final pantheonFilter = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Filtrar por plano',
    );
    expect(pantheonFilter, findsOneWidget);
    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('D&D').last);
    await tester.pumpAndSettle();
    expect(find.text('20 de 75 deidades'), findsOneWidget);

    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Olimpo').last);
    await tester.pumpAndSettle();
    expect(find.text('19 de 75 deidades'), findsOneWidget);

    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faraónico').last);
    await tester.pumpAndSettle();
    expect(find.text('15 de 75 deidades'), findsOneWidget);

    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Asgardiano').last);
    await tester.pumpAndSettle();
    expect(find.text('20 de 75 deidades'), findsOneWidget);

    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fe del Sol').last);
    await tester.pumpAndSettle();
    expect(find.text('1 de 75 deidades'), findsOneWidget);
    expect(find.text('Taia (Aspecto Creador / Destructor)'), findsOneWidget);

    await tester.tap(pantheonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos').last);
    await tester.pumpAndSettle();

    final clericAlignmentFilter = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText ==
              'Filtrar por alineamiento de clérigos',
    );
    expect(clericAlignmentFilter, findsOneWidget);
    await tester.tap(clericAlignmentFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CM').last);
    await tester.pumpAndSettle();
    expect(find.text('20 de 75 deidades'), findsOneWidget);

    await tester.tap(clericAlignmentFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos').last);
    await tester.pumpAndSettle();

    final domainFilter = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Filtrar por dominio',
    );
    expect(domainFilter, findsOneWidget);
    await tester.tap(domainFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agua').last);
    await tester.pumpAndSettle();
    expect(find.text('7 de 75 deidades'), findsOneWidget);

    final deityFilter = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText ==
              'Filtrar por nombre, ámbito, dominio o alineamiento',
    );
    await tester.enterText(deityFilter, 'Taia');
    await tester.pump();
    expect(find.text('1 de 75 deidades'), findsOneWidget);
    await tester.enterText(deityFilter, '');
    await tester.pump();

    await tester.tap(domainFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos').last);
    await tester.pumpAndSettle();

    await tester.enterText(deityFilter, 'Gungnir');
    await tester.pump();
    expect(find.text('1 de 75 deidades'), findsOneWidget);
    expect(find.text('Odín'), findsOneWidget);
    expect(find.text('Asgardiano'), findsWidgets);
    await tester.tap(find.text('Odín'));
    await tester.pumpAndSettle();
    expect(find.text('Asgardiano'), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
    expect(
      find.text(
        'Padre de Todos y rey de Asgard. Sacrificó su ojo por la sabiduría divina y descubrió los secretos del poder de las runas.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 350));

    final deityPreferences = await SharedPreferences.getInstance();
    expect(
      deityPreferences.getString('character-sheet-v1'),
      contains('"deity":"Odín"'),
    );

    await tester.tap(find.byTooltip('Ver descripción de la deidad'));
    await tester.pumpAndSettle();
    expect(find.text('Gungnir (Lanza)'), findsOneWidget);
    final deityDetailLabels = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    expect(
      deityDetailLabels.indexOf('Descripción'),
      greaterThan(deityDetailLabels.indexOf('Arma predilecta')),
    );
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

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
