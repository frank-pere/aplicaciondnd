import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ink = Color(0xFF181713);
const _panel = Color(0xFF22211D);
const _gold = Color(0xFFD5AD68);
const _muted = Color(0xFFAAA59A);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DndCompanionApp());
}

class Spell {
  const Spell({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.target,
    required this.duration,
    required this.save,
    required this.spellResistance,
    required this.classes,
  });

  factory Spell.fromRow(List<dynamic> row) => Spell(
        name: row[0] as String,
        level: row[1] as int,
        school: row[2] as String,
        castingTime: row[3] as String,
        range: row[4] as String,
        target: row[5] as String,
        duration: row[6] as String,
        save: row[7] as String,
        spellResistance: row[8] as String,
        classes: row[9] as String,
      );

  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String target;
  final String duration;
  final String save;
  final String spellResistance;
  final String classes;
}

class CharacterAlignment {
  const CharacterAlignment({
    required this.category,
    required this.name,
    required this.abbreviation,
    required this.description,
  });

  factory CharacterAlignment.fromRow(List<dynamic> row) => CharacterAlignment(
        category: row[0] as String,
        name: row[1] as String,
        abbreviation: row[2] as String,
        description: row[3] as String,
      );

  final String category;
  final String name;
  final String abbreviation;
  final String description;
}

class CharacterDeity {
  const CharacterDeity({
    required this.name,
    required this.pantheon,
    required this.description,
    required this.divineRank,
    required this.alignment,
    required this.clericAlignments,
    required this.portfolio,
    required this.domains,
    required this.favoredWeapon,
  });

  factory CharacterDeity.fromJson(Map<String, dynamic> json) => CharacterDeity(
        name: json['name'] as String,
        pantheon: json['pantheon'] as String,
        description: json['description'] as String,
        divineRank: json['divineRank'] as String,
        alignment: json['alignment'] as String,
        clericAlignments: json['clericAlignments'] as String,
        portfolio: json['portfolio'] as String,
        domains: json['domains'] as String,
        favoredWeapon: json['favoredWeapon'] as String,
      );

  final String name;
  final String pantheon;
  final String description;
  final String divineRank;
  final String alignment;
  final String clericAlignments;
  final String portfolio;
  final String domains;
  final String favoredWeapon;
}

class CharacterSheet {
  CharacterSheet(this.values);

  factory CharacterSheet.empty() => CharacterSheet({
        for (final key in _fieldLabels.keys) key: '',
        for (final key in _abilityLabels.keys) key: '',
      });

  factory CharacterSheet.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El archivo de la ficha no tiene un formato válido.',
      );
    }
    return CharacterSheet({
      for (final key in _fieldLabels.keys)
        key: decoded[key] is String ? decoded[key] as String : '',
      for (final key in _abilityLabels.keys)
        key: decoded[key] is String ? decoded[key] as String : '',
    });
  }

  final Map<String, String> values;

  String operator [](String key) => values[key] ?? '';

  String toJson() => jsonEncode(values);
}

const _fieldLabels = <String, String>{
  'character': 'Nombre del personaje',
  'player': 'Jugador',
  'race': 'Raza',
  'class': 'Clase y nivel',
  'alignment': 'Alineamiento',
  'deity': 'Deidad',
  'size': 'Tamaño',
  'age': 'Edad',
  'height': 'Altura',
  'weight': 'Peso',
  'experience': 'Experiencia',
  'hp': 'Puntos de golpe',
  'initiative': 'Iniciativa',
  'speed': 'Velocidad',
  'armorClass': 'Clase de armadura',
  'touch': 'Toque',
  'flatFooted': 'Desprevenido',
  'baseAttack': 'Ataque base',
  'grapple': 'Agarre',
  'fortitude': 'Fortaleza',
  'reflex': 'Reflejos',
  'will': 'Voluntad',
  'skills': 'Habilidades y rangos',
  'feats': 'Dotes',
  'equipment': 'Equipo y tesoro',
  'notes': 'Conjuros conocidos, preparados y notas',
};

const _abilityLabels = <String, String>{
  'strength': 'Fuerza',
  'dexterity': 'Destreza',
  'constitution': 'Constitución',
  'intelligence': 'Inteligencia',
  'wisdom': 'Sabiduría',
  'charisma': 'Carisma',
};

class DndCompanionApp extends StatefulWidget {
  const DndCompanionApp({super.key});

  @override
  State<DndCompanionApp> createState() => _DndCompanionAppState();
}

class _DndCompanionAppState extends State<DndCompanionApp> {
  late final Future<
      ({
        List<Spell> spells,
        List<CharacterAlignment> alignments,
        List<CharacterDeity> deities,
        CharacterSheet sheet
      })> _startup = _load();
  int _selectedIndex = 0;

  Future<
      ({
        List<Spell> spells,
        List<CharacterAlignment> alignments,
        List<CharacterDeity> deities,
        CharacterSheet sheet
      })> _load() async {
    final rawSpells = await rootBundle.loadString('assets/data/spells.json');
    final rows = jsonDecode(rawSpells);
    if (rows is! List) {
      throw const FormatException(
        'El compendio local no tiene un formato válido.',
      );
    }
    final spells = rows.map((row) {
      if (row is! List<dynamic> || row.length != 10) {
        throw const FormatException(
          'Un conjuro del compendio local no tiene los diez campos esperados.',
        );
      }
      return Spell.fromRow(row);
    }).toList(growable: false);
    final rawAlignments =
        await rootBundle.loadString('assets/data/alignments.json');
    final alignmentRows = jsonDecode(rawAlignments);
    if (alignmentRows is! List) {
      throw const FormatException(
        'Los alineamientos locales no tienen un formato válido.',
      );
    }
    final alignments = alignmentRows.map((row) {
      if (row is! List<dynamic> || row.length != 4) {
        throw const FormatException(
          'Un alineamiento local no tiene los cuatro campos esperados.',
        );
      }
      return CharacterAlignment.fromRow(row);
    }).toList(growable: false);
    final rawDeities = await rootBundle.loadString('assets/data/deities.json');
    final deityRows = jsonDecode(rawDeities);
    if (deityRows is! List) {
      throw const FormatException(
        'Las deidades locales no tienen un formato válido.',
      );
    }
    final deities = deityRows.map((row) {
      if (row is! Map<String, dynamic> ||
          row.values.any((value) => value is! String)) {
        throw const FormatException(
          'Una deidad local no tiene el formato esperado.',
        );
      }
      return CharacterDeity.fromJson(row);
    }).toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString('character-sheet-v1');
    final sheet =
        saved == null ? CharacterSheet.empty() : CharacterSheet.fromJson(saved);
    return (
      spells: spells,
      alignments: alignments,
      deities: deities,
      sheet: sheet
    );
  }

  Future<void> _saveSheet(CharacterSheet sheet) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      'character-sheet-v1',
      sheet.toJson(),
    );
    if (!saved) {
      throw StateError('No fue posible guardar la ficha en este dispositivo.');
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Crónicas 3.5',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _ink,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _gold,
            brightness: Brightness.dark,
            surface: _panel,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF292822),
            labelStyle: const TextStyle(color: _muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF39372F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold),
            ),
          ),
        ),
        home: FutureBuilder(
          future: _startup,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _StartupError(message: snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: _gold)),
              );
            }
            final data = snapshot.data!;
            return _HomeShell(
              spells: data.spells,
              alignments: data.alignments,
              deities: data.deities,
              initialSheet: data.sheet,
              selectedIndex: _selectedIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
              onSaveSheet: _saveSheet,
            );
          },
        ),
      );
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo abrir la aplicación',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  const Text(
                    'Revisa que el compendio local esté incluido y que el almacenamiento del navegador esté habilitado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _HomeShell extends StatelessWidget {
  const _HomeShell({
    required this.spells,
    required this.alignments,
    required this.deities,
    required this.initialSheet,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSaveSheet,
  });

  final List<Spell> spells;
  final List<CharacterAlignment> alignments;
  final List<CharacterDeity> deities;
  final CharacterSheet initialSheet;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Future<void> Function(CharacterSheet) onSaveSheet;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge),
      label: 'Personaje',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: 'Conjuros',
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final views = [
            _CharacterScreen(
              initialSheet: initialSheet,
              alignments: alignments,
              deities: deities,
              onSave: onSaveSheet,
            ),
            _SpellbookScreen(spells: spells),
          ];
          return Scaffold(
            appBar: AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: _gold),
                  SizedBox(width: 10),
                  Text('CRÓNICAS 3.5', style: TextStyle(letterSpacing: 1.6)),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Center(
                    child: Text(
                      '${spells.length} CONJUROS',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: wide
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onSelected,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: _ink,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.badge_outlined),
                            selectedIcon: Icon(Icons.badge),
                            label: Text('Personaje'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.auto_awesome_outlined),
                            selectedIcon: Icon(Icons.auto_awesome),
                            label: Text('Conjuros'),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1, color: Color(0xFF35332C)),
                      Expanded(
                        child:
                            IndexedStack(index: selectedIndex, children: views),
                      ),
                    ],
                  )
                : IndexedStack(index: selectedIndex, children: views),
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onSelected,
                    destinations: _destinations,
                  ),
          );
        },
      );
}

class _CharacterScreen extends StatefulWidget {
  const _CharacterScreen({
    required this.initialSheet,
    required this.alignments,
    required this.deities,
    required this.onSave,
  });

  final CharacterSheet initialSheet;
  final List<CharacterAlignment> alignments;
  final List<CharacterDeity> deities;
  final Future<void> Function(CharacterSheet) onSave;

  @override
  State<_CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<_CharacterScreen> {
  Timer? _saveTimer;
  late final Map<String, TextEditingController> _controllers = {
    for (final key in {..._fieldLabels.keys, ..._abilityLabels.keys})
      key: TextEditingController(text: widget.initialSheet[key]),
  };
  String? _saveError;

  @override
  void dispose() {
    _saveTimer?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateSheet() {
    final sheet = CharacterSheet({
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    });
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        await widget.onSave(sheet);
        if (mounted && _saveError != null) {
          setState(() => _saveError = null);
        }
      } catch (error) {
        if (mounted) setState(() => _saveError = error.toString());
      }
    });
  }

  Widget _field(String key, {int lines = 1}) => TextField(
        controller: _controllers[key],
        onChanged: (_) => _updateSheet(),
        minLines: lines == 1 ? 1 : lines,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: _fieldLabels[key],
          alignLabelWithHint: lines > 1,
        ),
      );

  int? _abilityModifier(String key) {
    final score = int.tryParse(_controllers[key]!.text.trim());
    return score == null ? null : ((score - 10) / 2).floor();
  }

  Widget _readOnlyAbilityCell(String label, int? modifier) {
    final value = modifier == null
        ? '—'
        : modifier >= 0
            ? '+$modifier'
            : '$modifier';
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value),
    );
  }

  void _showAlignmentDetails(CharacterAlignment alignment) {
    showDialog<void>(
      context: context,
      builder: (context) => _AlignmentDetailsDialog(alignment: alignment),
    );
  }

  void _showDeityDetails(CharacterDeity deity) {
    showDialog<void>(
      context: context,
      builder: (context) => _DeityDetailsDialog(deity: deity),
    );
  }

  Future<void> _chooseDeity() async {
    final deity = await showDialog<CharacterDeity>(
      context: context,
      builder: (context) => _DeityPickerDialog(deities: widget.deities),
    );
    if (deity == null || !mounted) return;
    setState(() => _controllers['deity']!.text = deity.name);
    _updateSheet();
    _showDeityDetails(deity);
  }

  Widget _alignmentField() {
    final selectedName = _controllers['alignment']!.text;
    CharacterAlignment? selectedAlignment;
    for (final alignment in widget.alignments) {
      if (alignment.name == selectedName) {
        selectedAlignment = alignment;
        break;
      }
    }
    final alignmentForDetails = selectedAlignment;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedAlignment?.name,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: _fieldLabels['alignment'],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            items: [
              for (final alignment in widget.alignments)
                DropdownMenuItem(
                  value: alignment.name,
                  child: Text(
                    alignment.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (name) {
              if (name == null) return;
              final alignment =
                  widget.alignments.firstWhere((item) => item.name == name);
              setState(() {
                _controllers['alignment']!.text = name;
              });
              _updateSheet();
              _showAlignmentDetails(alignment);
            },
          ),
        ),
        IconButton(
          tooltip: 'Ver descripción del alineamiento',
          onPressed: alignmentForDetails == null
              ? null
              : () => _showAlignmentDetails(alignmentForDetails),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }

  Widget _deityField() {
    final selectedName = _controllers['deity']!.text;
    CharacterDeity? selectedDeity;
    for (final deity in widget.deities) {
      if (deity.name == selectedName) {
        selectedDeity = deity;
        break;
      }
    }
    final deityForDetails = selectedDeity;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _chooseDeity,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: _fieldLabels['deity'],
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              child: Text(
                selectedName.isEmpty ? 'Seleccionar deidad' : selectedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedName.isEmpty ? _muted : Colors.white,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Ver descripción de la deidad',
          onPressed: deityForDetails == null
              ? null
              : () => _showDeityDetails(deityForDetails),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF39372F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _gold, size: 20),
                const SizedBox(width: 9),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      );

  Widget _grid(List<Widget> fields, {double width = 180}) => LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in fields)
              SizedBox(
                width: constraints.maxWidth < width + 24
                    ? constraints.maxWidth
                    : width,
                child: field,
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final abilitySection = _section('Características', Icons.bolt_outlined, [
      Column(
        children: [
          for (final entry in _abilityLabels.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: _controllers[entry.key],
                      onChanged: (_) => setState(_updateSheet),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: entry.value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: _readOnlyAbilityCell(
                      'Mod.',
                      _abilityModifier(entry.key),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: _readOnlyAbilityCell('Temp.', null),
                  ),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 10),
      const Text(
        'El modificador se calcula con (puntuación − 10) ÷ 2, redondeado hacia abajo. El temporal está pendiente.',
        style: TextStyle(color: _muted, fontSize: 12),
      ),
      const SizedBox(height: 16),
      const Row(
        children: [
          Icon(Icons.shield_outlined, color: _gold, size: 20),
          SizedBox(width: 9),
          Text(
            'TIROS DE SALVACIÓN',
            style: TextStyle(
              color: _gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.25,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final key in ['fortitude', 'reflex', 'will'])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _field(key),
            ),
        ],
      ),
    ]);
    final combatSection =
        _section('Combate y defensas', Icons.shield_outlined, [
      _grid([
        _field('hp'),
        _field('initiative'),
        _field('speed'),
        _field('armorClass'),
        _field('touch'),
        _field('flatFooted'),
        _field('baseAttack'),
        _field('grapple'),
      ]),
    ]);
    final content = [
      _section('Identidad', Icons.person_outline, [
        _grid([
          _field('character'),
          _field('player'),
          _field('race'),
          _field('class'),
          _alignmentField(),
          _deityField(),
          _field('size'),
          _field('age'),
          _field('height'),
          _field('weight'),
          _field('experience'),
        ]),
      ]),
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                abilitySection,
                const SizedBox(height: 16),
                combatSection,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: abilitySection),
              const SizedBox(width: 16),
              Expanded(child: combatSection),
            ],
          );
        },
      ),
      _section('Aventurero', Icons.backpack_outlined, [
        _field('skills', lines: 3),
        const SizedBox(height: 12),
        _field('feats', lines: 3),
        const SizedBox(height: 12),
        _field('equipment', lines: 3),
        const SizedBox(height: 12),
        _field('notes', lines: 4),
      ]),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu próxima leyenda empieza aquí.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Completa tu hoja; los cambios se guardan en este dispositivo.',
                  style: TextStyle(color: _muted),
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Error al guardar: $_saveError',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 22),
                for (var i = 0; i < content.length; i++) ...[
                  content[i],
                  if (i < content.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpellbookScreen extends StatefulWidget {
  const _SpellbookScreen({required this.spells});

  final List<Spell> spells;

  @override
  State<_SpellbookScreen> createState() => _SpellbookScreenState();
}

class _SpellbookScreenState extends State<_SpellbookScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _level;
  String? _className;

  static const _classNames = [
    'Mago',
    'Hechicero',
    'Clérigo',
    'Druida',
    'Bardo',
    'Paladín',
    'Explorador',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Spell> get _filtered => widget.spells.where((spell) {
        final text =
            '${spell.name} ${spell.school} ${spell.classes}'.toLowerCase();
        return text.contains(_query.toLowerCase()) &&
            (_level == null || spell.level == _level) &&
            (_className == null || spell.classes.contains(_className!));
      }).toList(growable: false);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          final spells = _filtered;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compendio de conjuros',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Busca por nombre, escuela o clase y explora los detalles.',
                        style: TextStyle(color: _muted),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: wide ? 420 : constraints.maxWidth,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value.trim()),
                              decoration: InputDecoration(
                                labelText: 'Buscar conjuros',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _query.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Limpiar búsqueda',
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _query = '');
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: wide ? 180 : constraints.maxWidth,
                            child: DropdownButtonFormField<int?>(
                              initialValue: _level,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Nivel',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Todos los niveles'),
                                ),
                                for (var level = 0; level <= 9; level++)
                                  DropdownMenuItem<int?>(
                                    value: level,
                                    child: Text('Nivel $level'),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _level = value),
                            ),
                          ),
                          SizedBox(
                            width: wide ? 200 : constraints.maxWidth,
                            child: DropdownButtonFormField<String?>(
                              initialValue: _className,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Clase',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todas las clases'),
                                ),
                                for (final name in _classNames)
                                  DropdownMenuItem<String?>(
                                    value: name,
                                    child: Text(name),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _className = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${spells.length} de ${widget.spells.length} conjuros',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      if (spells.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No hay conjuros que coincidan con esos filtros.',
                              style: TextStyle(color: _muted),
                            ),
                          ),
                        )
                      else
                        for (final spell in spells)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SpellCard(
                              spell: spell,
                              onTap: () => showDialog<void>(
                                context: context,
                                builder: (context) =>
                                    _SpellDetailsDialog(spell: spell),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class _SpellCard extends StatelessWidget {
  const _SpellCard({required this.spell, required this.onTap});

  final Spell spell;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: _panel,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF39372F)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF393126),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${spell.level}',
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spell.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${spell.school} · ${spell.classes}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: _muted),
              ],
            ),
          ),
        ),
      );
}

class _PantheonCapsule extends StatelessWidget {
  const _PantheonCapsule({required this.pantheon});

  final String pantheon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF393126),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF665238)),
        ),
        child: Text(
          pantheon,
          style: const TextStyle(
            color: _gold,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _DeityPickerDialog extends StatefulWidget {
  const _DeityPickerDialog({required this.deities});

  final List<CharacterDeity> deities;

  @override
  State<_DeityPickerDialog> createState() => _DeityPickerDialogState();
}

class _DeityPickerDialogState extends State<_DeityPickerDialog> {
  String _query = '';
  String _pantheon = 'Todos';
  String _clericAlignment = 'Todos';
  String _domain = 'Todos';

  static const _clericAlignmentOptions = [
    'LB',
    'LN',
    'LM',
    'NB',
    'N',
    'NM',
    'CB',
    'CN',
    'CM',
  ];

  List<String> get _domainOptions => widget.deities
      .expand((deity) => deity.domains.split(','))
      .map((domain) => domain.trim().replaceAll(RegExp(r'\.+$'), ''))
      .where((domain) => domain.isNotEmpty && domain.toLowerCase() != 'todos')
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  List<CharacterDeity> get _filteredDeities {
    final query = _query.trim().toLowerCase();
    return widget.deities.where((deity) {
      final searchable = [
        deity.name,
        deity.description,
        deity.divineRank,
        deity.alignment,
        deity.clericAlignments,
        deity.portfolio,
        deity.domains,
        deity.favoredWeapon,
      ].join(' ').toLowerCase();
      final clericAlignmentMatches = _clericAlignment == 'Todos' ||
          deity.clericAlignments.toLowerCase().contains('todos') ||
          deity.clericAlignments
              .split(',')
              .any((alignment) => alignment.trim() == _clericAlignment);
      final domains = deity.domains
          .split(',')
          .map((domain) => domain.trim().replaceAll(RegExp(r'\.+$'), ''));
      final domainMatches = _domain == 'Todos' ||
          deity.domains.toLowerCase().contains('todos') ||
          domains.any((domain) => domain.toLowerCase() == _domain.toLowerCase());

      return searchable.contains(query) &&
          (_pantheon == 'Todos' || deity.pantheon == _pantheon) &&
          clericAlignmentMatches &&
          domainMatches;
    }).toList(growable: false);
  }

  Widget _clericAlignmentDropdown() => DropdownButtonFormField<String>(
        initialValue: _clericAlignment,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Filtrar por alineamiento de clérigos',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        items: [
          for (final alignment in ['Todos', ..._clericAlignmentOptions])
            DropdownMenuItem(
              value: alignment,
              child: Text(alignment),
            ),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _clericAlignment = value);
        },
      );

  Widget _domainDropdown() => DropdownButtonFormField<String>(
        initialValue: _domain,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Filtrar por dominio',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        items: [
          for (final domain in ['Todos', ..._domainOptions])
            DropdownMenuItem(
              value: domain,
              child: Text(domain),
            ),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _domain = value);
        },
      );

  @override
  Widget build(BuildContext context) {
    final deities = _filteredDeities;
    final screenSize = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: _panel,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: screenSize.width > 760 ? 680 : screenSize.width * 0.9,
        height: screenSize.height * 0.82,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar deidad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  labelText:
                      'Filtrar por nombre, ámbito, dominio o alineamiento',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _pantheon,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por plano',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: [
                  for (final pantheon in [
                    'Todos',
                    'D&D',
                    'Olimpo',
                    'Faraónico',
                    'Asgardiano',
                    'Fe del Sol',
                  ])
                    DropdownMenuItem(
                      value: pantheon,
                      child: Text(pantheon),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _pantheon = value);
                },
              ),
              const SizedBox(height: 12),
              if (screenSize.width > 620)
                Row(
                  children: [
                    Expanded(child: _clericAlignmentDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _domainDropdown()),
                  ],
                )
              else ...[
                _clericAlignmentDropdown(),
                const SizedBox(height: 12),
                _domainDropdown(),
              ],
              const SizedBox(height: 12),
              Text(
                '${deities.length} de ${widget.deities.length} deidades',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: deities.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay deidades que coincidan con la búsqueda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: deities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final deity = deities[index];
                          return Card(
                            color: const Color(0xFF292822),
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(child: Text(deity.name)),
                                  const SizedBox(width: 8),
                                  _PantheonCapsule(pantheon: deity.pantheon),
                                ],
                              ),
                              subtitle: Text(
                                '${deity.alignment} · ${deity.portfolio}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: _muted,
                              ),
                              onTap: () => Navigator.of(context).pop(deity),
                            ),
                          );
                        },
                      ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeityDetailsDialog extends StatelessWidget {
  const _DeityDetailsDialog({required this.deity});

  final CharacterDeity deity;

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _panel,
        title: Row(
          children: [
            Expanded(child: Text(deity.name)),
            const SizedBox(width: 8),
            _PantheonCapsule(pantheon: deity.pantheon),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Ámbito de poder', deity.portfolio),
              _detail('Rango divino', deity.divineRank),
              _detail('Alineamiento', deity.alignment),
              _detail('Alineamientos de clérigos', deity.clericAlignments),
              _detail('Dominios', deity.domains),
              _detail('Arma predilecta', deity.favoredWeapon),
              const Divider(height: 20, color: Color(0xFF39372F)),
              _detail('Descripción', deity.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
}

class _AlignmentDetailsDialog extends StatelessWidget {
  const _AlignmentDetailsDialog({required this.alignment});

  final CharacterAlignment alignment;

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _panel,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF393126),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                alignment.abbreviation,
                style: const TextStyle(color: _gold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(alignment.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categoría moral',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(alignment.category),
              const SizedBox(height: 16),
              const Text(
                'Descripción',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(alignment.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
}

class _SpellDetailsDialog extends StatelessWidget {
  const _SpellDetailsDialog({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: _panel,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF393126),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Text('${spell.level}', style: const TextStyle(color: _gold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(spell.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detail('Escuela', spell.school),
              _detail('Tiempo de lanzamiento', spell.castingTime),
              _detail('Alcance', spell.range),
              _detail('Objetivo / área / efecto', spell.target),
              _detail('Duración', spell.duration),
              _detail('Tiro de salvación', spell.save),
              _detail('Resistencia a conjuros', spell.spellResistance),
              _detail('Clases', spell.classes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 145,
              child: Text(
                label,
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
