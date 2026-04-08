part of '../tasks/presentation/matrix_page.dart';

// ---------------------------------------------------------------------------
// Widget Appearance Sheet
// ---------------------------------------------------------------------------

class _WidgetAppearanceSheet extends StatefulWidget {
  const _WidgetAppearanceSheet({required this.service});

  final WidgetAppearanceService service;

  @override
  State<_WidgetAppearanceSheet> createState() => _WidgetAppearanceSheetState();
}

class _WidgetAppearanceSheetState extends State<_WidgetAppearanceSheet> {
  late WidgetAppearanceSettings _settings;
  bool _themeDefaultApplied = false;

  // Hand-curated dark/light presets (scaffold bg of current theme is prepended dynamically).
  static const _bgPresets = <int>[
    0x1C1B1F,
    0x0D1B2A,
    0x0F2D1F,
    0x1E2832,
    0x2C2C2E,
    0x2A0D0D,
    0x2D1A0E,
  ];

  static const _quadrantOrder = ['q1', 'q2', 'q3', 'q4'];

  @override
  void initState() {
    super.initState();
    _settings = widget.service.current;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeDefaultApplied) {
      _themeDefaultApplied = true;
      if (_settings.bgColorValue ==
          WidgetAppearanceSettings.defaults().bgColorValue) {
        final scaffoldColor = Theme.of(
          context,
        ).scaffoldBackgroundColor.toARGB32();
        _settings = _settings.copyWith(bgColorValue: scaffoldColor);
      }
    }
  }

  Future<void> _save() async {
    await widget.service.save(_settings);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Modifiche salvate, potrebbe essere necessario ricreare il widget per applicarle.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alphaPercent = ((_settings.bgAlpha / 255) * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Aspetto del widget',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 24),

              // ── Sfondo ──────────────────────────────────────────────────
              Text('Sfondo', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    [
                      // Scaffold background of current theme is always offered first.
                      Theme.of(context).scaffoldBackgroundColor.toARGB32(),
                      ..._bgPresets,
                    ].map((colorValue) {
                      final isSelected = _settings.bgColorValue == colorValue;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _settings = _settings.copyWith(
                            bgColorValue: colorValue,
                          ),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xFF000000 | colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(120),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Trasparenza: $alphaPercent%'),
                  Expanded(
                    child: Slider(
                      min: 128,
                      max: 255,
                      divisions: 127,
                      value: _settings.bgAlpha.toDouble(),
                      onChanged: (v) => setState(
                        () =>
                            _settings = _settings.copyWith(bgAlpha: v.round()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Testo ────────────────────────────────────────────────────
              Text(
                'Dimensione testo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Center(
                child: SegmentedButton<WidgetTextSize>(
                  segments: const [
                    ButtonSegment(
                      value: WidgetTextSize.small,
                      label: Text('Piccolo'),
                    ),
                    ButtonSegment(
                      value: WidgetTextSize.medium,
                      label: Text('Medio'),
                    ),
                    ButtonSegment(
                      value: WidgetTextSize.large,
                      label: Text('Grande'),
                    ),
                  ],
                  selected: {_settings.textSize},
                  onSelectionChanged: (s) => setState(
                    () => _settings = _settings.copyWith(textSize: s.first),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Colore testo ─────────────────────────────────────────────
              Text(
                'Colore testo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Center(
                child: SegmentedButton<WidgetTextColor>(
                  segments: const [
                    ButtonSegment(
                      value: WidgetTextColor.white,
                      label: Text('Bianco'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: WidgetTextColor.black,
                      label: Text('Nero'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {_settings.textColor},
                  onSelectionChanged: (s) => setState(
                    () => _settings = _settings.copyWith(textColor: s.first),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Quadranti', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              ..._quadrantOrder.map((key) {
                final isVisible = _settings.visibleQuadrants.contains(key);
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(EisenhowerQuadrantX.fromValue(key).fullName),
                  value: isVisible,
                  onChanged: (checked) {
                    final next = Set<String>.from(_settings.visibleQuadrants);
                    if (checked == true) {
                      next.add(key);
                    } else {
                      next.remove(key);
                    }
                    setState(
                      () => _settings = _settings.copyWith(
                        visibleQuadrants: next,
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Salva'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
