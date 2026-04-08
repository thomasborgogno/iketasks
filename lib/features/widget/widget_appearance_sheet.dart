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

  static const _bgPresetsDark = <int>[
    0xFF1A2A3A, // Blu Navy
    0xFF1B3329, // Verde Bosco
    0xFF2E1A47, // Viola Navy
    0xFF4A1F2D, // Borgogna
    0xFF2D3018, // Verde Oliva
    0xFF3C3C3C, // Grigio Antracite
  ];

  static const _bgPresetsLight = <int>[
    0xFFD1E3F5, // Blu Cielo
    0xFFD5EDDB, // Verde Menta
    0xFFE1D5F5, // Lavanda
    0xFFF5D5DC, // Rosa Antico
    0xFFE9EDD5, // Lime Pallido
    0xFFE5E5E5, // Grigio Perla
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
              WidgetAppearanceSettings.defaults().bgColorValue &&
          _settings.themeMode == WidgetThemeMode.system) {
        _settings = _settings.copyWith(
          bgColorValue: _scaffoldBgForMode(WidgetThemeMode.system),
        );
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the scaffold bg ARGB int for [mode] (using live theme for system).
  int _scaffoldBgForMode(WidgetThemeMode mode) {
    switch (mode) {
      case WidgetThemeMode.dark:
        return 0xFF1C1B1F;
      case WidgetThemeMode.light:
        return 0xFFF6F9FB;
      case WidgetThemeMode.system:
        return Theme.of(context).scaffoldBackgroundColor.toARGB32();
    }
  }

  bool _isDarkMode(WidgetThemeMode mode) {
    if (mode == WidgetThemeMode.dark) return true;
    if (mode == WidgetThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  List<int> _presetsForMode(WidgetThemeMode mode) =>
      _isDarkMode(mode) ? _bgPresetsDark : _bgPresetsLight;

  WidgetTextColor _defaultTextColorForMode(WidgetThemeMode mode) =>
      _isDarkMode(mode) ? WidgetTextColor.white : WidgetTextColor.black;

  void _onThemeModeChanged(WidgetThemeMode newMode) {
    final newBgColor = newMode == WidgetThemeMode.system
        ? _scaffoldBgForMode(newMode)
        : _settings.bgColorValue;
    setState(() {
      _settings = _settings.copyWith(
        themeMode: newMode,
        bgColorValue: newBgColor,
        textColor: _defaultTextColorForMode(newMode),
      );
    });
  }

  Future<void> _save() async {
    await widget.service.save(_settings);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Widget aggiornato.')));
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
              const SizedBox(height: 8),

              // ── Tema ────────────────────────────────────────────────────
              Text('Tema', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Center(
                child: SegmentedButton<WidgetThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: WidgetThemeMode.system,
                      label: Text('Sistema'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: WidgetThemeMode.light,
                      label: Text('Chiaro'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: WidgetThemeMode.dark,
                      label: Text('Scuro'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {_settings.themeMode},
                  onSelectionChanged: (s) => _onThemeModeChanged(s.first),
                ),
              ),
              const SizedBox(height: 24),

              // ── Sfondo ──────────────────────────────────────────────────
              Text('Sfondo', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Opacity(
                opacity: _settings.themeMode == WidgetThemeMode.system
                    ? 0.35
                    : 1.0,
                child: IgnorePointer(
                  ignoring: _settings.themeMode == WidgetThemeMode.system,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        [
                          _scaffoldBgForMode(_settings.themeMode),
                          ..._presetsForMode(_settings.themeMode),
                        ].map((colorValue) {
                          final isSelected =
                              _settings.bgColorValue == colorValue;
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
                ),
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
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: WidgetTextColor.white,
                      label: const Text('Bianco'),
                      icon: _isDarkMode(_settings.themeMode)
                          ? const Icon(Icons.circle)
                          : const Icon(Icons.circle_outlined),
                    ),
                    ButtonSegment(
                      value: WidgetTextColor.black,
                      label: const Text('Nero'),
                      icon: _isDarkMode(_settings.themeMode)
                          ? const Icon(Icons.circle_outlined)
                          : const Icon(Icons.circle),
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
